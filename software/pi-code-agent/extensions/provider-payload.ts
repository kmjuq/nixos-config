// ============================================================================
// 设计思路
// ----------------------------------------------------------------------------
// 本扩展通过 before_provider_request / after_provider_response / message_end
// 三个钩子做"请求/响应抓包"，并把【请求 + 响应 + 用量统计】配对成一条日志块，
// 在响应完成后才一次性写入，保证日志中请求与响应一一对应。
//
//  请求流程：
//    before_provider_request  暂存请求（不立即写日志），并启动超时定时器
//    after_provider_response  给最近的请求补上 status/headers；
//                             若 status >= 400（异常响应）→ 立即落盘【请求+错误】
//                             否则继续等待 message_end 的用量
//    message_end              给最近的请求补上 usage → 一次性落盘【请求+响应+用量】
//    超时定时器到期           → 落盘【请求+超时无响应】
//    session_shutdown         清理未完成的请求 → 落盘【请求+会话结束未完成】
//
//  配对说明：before/after_provider_request/response 事件没有请求 ID，但 pi 对 provider
//  请求是串行的，因此按"最近一次未完成的请求"进行 FIFO 配对。
//
//  浏览命令 /payload-log [条目数]：
//    TUI 下弹出自定义浏览组件，默认定位到【最新一条】日志，支持：
//      ↓/j  看更早的日志条目；已到最早则滚动内容
//      ↑/k  看更新的日志条目；已到最新则滚动内容
//      PgUp/PgDn 或 ←/→  内容区上下滚动
//      q / Esc   退出
//    RPC 下退化为可滚动选择器；print/json 下直接打印。
//
//  日志增长控制：
//    - 按【请求对数】保留：最多 maxEntries（默认 5000）对请求，超过自动裁掉最旧的
//    - 日志过多时用户可自行用 /payload-log-clear 清空，或调大/调小 maxEntries
//  超时时间默认 10 分钟，可用 timeoutMs 配置覆盖。
//  日志路径：默认写入系统临时目录 os.tmpdir()/pi（可用配置 dir 字段覆盖），
//  每个会话单独一个文件 payload-<sessionId>.log，不写入项目 .pi 目录。
// ============================================================================
import { appendFileSync, existsSync, mkdirSync, readFileSync, unlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createHash } from "node:crypto";
import { type ExtensionAPI, type Theme } from "@earendil-works/pi-coding-agent";
import { matchesKey, truncateToWidth, wrapTextWithAnsi } from "@earendil-works/pi-tui";
import { registerConfig, type ConfigSchema, type ConfigValue } from "./shared/ext-config";

// ---------------------------------------------------------------------------
// 请求暂存（配对用）
// ---------------------------------------------------------------------------
interface UsageInfo {
  totalTokens?: number;
  input?: number;
  output?: number;
  cacheRead?: number;
  cacheWrite?: number;
  cost?: { total?: number };
}

interface PendingRequest {
  sessionId: string; // 发起请求时的会话 UUID，决定落盘到临时目录下哪个文件
  startedAt: number;
  model: string;
  payload: unknown;
  status?: number;
  headers?: Record<string, string>;
  written: boolean;
  timer?: ReturnType<typeof setTimeout>;
}

const pending: PendingRequest[] = [];

// ---------------------------------------------------------------------------
// 扩展统一配置：key + schema。值由 /cfg 或 /provider-payload-config 动态修改。
// ---------------------------------------------------------------------------
const EXT_KEY = "provider-payload";
const SCHEMA: ConfigSchema = {
  mode: {
    type: "enum",
    options: ["simple", "verbose"],
    default: "simple",
    description: "日志详细度：simple 只记摘要（模型/参数/用量），verbose 记完整请求体与响应头",
  },
  maxEntries: {
    type: "number",
    default: 5000,
    min: 1,
    description: "保留的请求对数，超过自动裁掉最旧",
  },
  timeoutMs: {
    type: "number",
    default: 10 * 60 * 1000,
    min: 1000,
    description: "请求超时毫秒数，超时未响应则落盘",
  },
  dir: {
    type: "string",
    default: "",
    description: "日志目录（留空则用系统临时目录 os.tmpdir()/pi）",
  },
};
let extConfig: ReturnType<typeof registerConfig> | undefined;
// 每次读取最新配置（不缓存），保证运行时切换即时生效。
function cur(): ConfigValue {
  return extConfig?.get() ?? {};
}

let entryCount = 0; // 当前日志文件中的请求对数（内存计数，session_start 时从文件校准）

const now = () => new Date().toISOString();

// 为每条请求生成确定性短 hash（基于 payload + 起始时间），用于日志标识。
function genHash(payload: unknown, startedAt: number): string {
  return createHash("sha1").update(`${JSON.stringify(payload)}\u0000${startedAt}`).digest("hex").slice(0, 8);
}

// ---------------------------------------------------------------------------
// 日志路径：默认写入系统临时目录 <os.tmpdir()>/pi，每个会话一个文件
// payload-<sessionId>.log，不写入项目 .pi 目录。可通过配置 dir 字段覆盖。
// ---------------------------------------------------------------------------
// 动态读取日志目录：配置 dir 为空时回退到系统临时目录（跨平台）。
function logDir(): string {
  const dir = (cur().dir as string)?.trim();
  return dir || join(tmpdir(), "pi");
}

function logFile(sessionId: string): string {
  return join(logDir(), `payload-${sessionId}.log`);
}

// 从 ctx 拿当前会话 UUID；无会话（如 print/json 模式）时兜底到一个匿名文件。
function sessionIdOf(ctx: { sessionManager: { getSessionId(): string | undefined } }): string {
  return ctx.sessionManager.getSessionId() ?? "anon";
}

// 写入日志（自动建目录 + 容错）。
function writeLog(sessionId: string, line: string) {
  try {
    mkdirSync(logDir(), { recursive: true });
    appendFileSync(logFile(sessionId), line, "utf8");
  } catch {
    // 抓包是辅助功能，任何写入失败都不应影响正常请求流程。
  }
}

// 超出 MAX_ENTRIES 时，裁掉最旧的条目，保留最新 MAX_ENTRIES 对请求。
function trimOldest(sessionId: string) {
  try {
    const file = logFile(sessionId);
    if (!existsSync(file)) return;
    const text = readFileSync(file, "utf8");
    const blocks = text.split(/(?=^===== REQ )/m);
    const header = blocks[0] ?? "";
    const entries = blocks.slice(1).filter((b) => b.trim());
    const maxEntries = (cur().maxEntries as number) || 5000;
    const overflow = entries.length - maxEntries;
    if (overflow <= 0) return;
    writeFileSync(file, header + entries.slice(overflow).join(""), "utf8");
    entryCount = maxEntries;
  } catch {
    // 裁剪失败不影响主流程。
  }
}

// 最近一次未落盘的请求（FIFO 配对）。
function latestUnwritten(): PendingRequest | undefined {
  for (let i = pending.length - 1; i >= 0; i--) {
    if (!pending[i].written) return pending[i];
  }
  return undefined;
}

function formatUsage(u: UsageInfo): string {
  const parts = [
    `total=${u.totalTokens ?? "?"}`,
    `in=${u.input ?? "?"}`,
    `out=${u.output ?? "?"}`,
    `cacheR=${u.cacheRead ?? "?"}`,
    `cacheW=${u.cacheWrite ?? "?"}`,
  ];
  const cost = u.cost?.total != null ? ` | cost=$${u.cost.total.toFixed(6)}` : "";
  return `${parts.join(" ")}${cost}`;
}

// 简略模式：从请求体里提取关键字段做摘要，避免落盘超大 JSON。
function summarizePayload(payload: unknown): string {
  try {
    const p = payload as Record<string, unknown>;
    const parts: string[] = [];
    if (typeof p.model === "string") parts.push(`model=${p.model}`);
    if (typeof p.temperature === "number") parts.push(`temp=${p.temperature}`);
    if (typeof p.max_tokens === "number") parts.push(`maxTokens=${p.max_tokens}`);
    else if (typeof p.maxTokens === "number") parts.push(`maxTokens=${p.maxTokens}`);
    if (typeof p.thinking === "string") parts.push(`thinking=${p.thinking}`);
    if (typeof p.thinkingLevel === "string") parts.push(`thinking=${p.thinkingLevel}`);
    const tools = (p as { tools?: unknown[] }).tools;
    if (Array.isArray(tools)) parts.push(`tools=${tools.length}`);
    const msgs = (p as { messages?: unknown[] }).messages;
    if (Array.isArray(msgs)) parts.push(`msgs=${msgs.length}`);
    return parts.length ? parts.join(", ") : JSON.stringify(p).slice(0, 300);
  } catch {
    return "(无法摘要)";
  }
}

// 一次性落盘：请求 + 附加信息（响应/用量/错误/超时），保证成对出现。
function flush(item: PendingRequest, tail: string[]) {
  const mode = cur().mode;
  const lines = [
    `===== REQ @ ${new Date(item.startedAt).toISOString()} | model=${item.model} | hash=${genHash(item.payload, item.startedAt)} =====`,
    mode === "verbose"
      ? JSON.stringify(item.payload, null, 2)
      : `    SUMMARY ${summarizePayload(item.payload)}`,
    ...tail,
  ];
  writeLog(item.sessionId, `\n${lines.join("\n")}\n`);
  item.written = true;
  entryCount++;
  const maxEntries = (cur().maxEntries as number) || 5000;
  if (entryCount > maxEntries) trimOldest(item.sessionId);
  if (item.timer) {
    clearTimeout(item.timer);
    item.timer = undefined;
  }
}

function armTimeout(item: PendingRequest) {
  const timeoutMs = (cur().timeoutMs as number) || 10 * 60 * 1000;
  item.timer = setTimeout(() => {
    if (item.written) return;
    flush(item, [`!!!! TIMEOUT @ ${now()} | 超过 ${Math.round(timeoutMs / 1000)}s 未收到响应`]);
  }, timeoutMs);
}

// ---------------------------------------------------------------------------
// 日志浏览组件（/payload-log）
// ---------------------------------------------------------------------------
interface LogEntry {
  title: string; // 第一行：===== REQ @ ts | model=... | hash=...
  body: string[]; // 其余行
}

function parseLog(text: string): LogEntry[] {
  const entries: LogEntry[] = [];
  const parts = text.split(/(?=^===== REQ )/m);
  for (const part of parts) {
    const trimmed = part.replace(/\n+$/, "");
    if (!trimmed.trim()) continue;
    const lines = trimmed.split("\n");
    entries.push({ title: lines[0] ?? "", body: lines.slice(1) });
  }
  return entries;
}

class LogBrowser {
  private entries: LogEntry[];
  private index: number; // 默认定位到最新一条
  private contentScroll = 0;
  private contentHeight = 20;
  private theme: Theme;
  private onClose: () => void;
  private cachedWidth?: number;
  private cachedLines?: string[];

  constructor(entries: LogEntry[], theme: Theme, onClose: () => void) {
    this.entries = entries;
    this.index = entries.length - 1;
    this.theme = theme;
    this.onClose = onClose;
  }

  handleInput(data: string): void {
    const n = this.entries.length;
    // 方向语义（默认定位最新，像分页器向下翻历史）：
    //   ↓/j = 看更早的条目；已是最早则降级为内容向下滚动
    //   ↑/k = 看更新的条目；已是最新则降级为内容向上滚动
    //   PgUp/PgDn 或 ←/→ = 内容区滚动；q/Esc = 退出
    if (matchesKey(data, "down") || matchesKey(data, "j")) {
      if (this.index > 0) {
        this.index--;
        this.contentScroll = 0;
      } else {
        this.contentScroll += this.contentHeight;
      }
      this.invalidate();
    } else if (matchesKey(data, "up") || matchesKey(data, "k")) {
      if (this.index < n - 1) {
        this.index++;
        this.contentScroll = 0;
      } else {
        this.contentScroll = Math.max(0, this.contentScroll - this.contentHeight);
      }
      this.invalidate();
    } else if (matchesKey(data, "pageup") || matchesKey(data, "left")) {
      this.contentScroll = Math.max(0, this.contentScroll - this.contentHeight);
      this.invalidate();
    } else if (matchesKey(data, "pagedown") || matchesKey(data, "right")) {
      this.contentScroll += this.contentHeight;
      this.invalidate();
    } else if (matchesKey(data, "escape") || matchesKey(data, "q") || matchesKey(data, "ctrl+c")) {
      this.onClose();
    }
  }

  render(width: number): string[] {
    if (this.cachedLines && this.cachedWidth === width) return this.cachedLines;
    const th = this.theme;
    const lines: string[] = [];
    const n = this.entries.length;
    const entry = this.entries[this.index];

    lines.push("");
    lines.push(
      truncateToWidth(
        th.fg("accent", " Provider Payload Log ") +
          th.fg("muted", `(第 ${this.index + 1} / ${n} 条${this.index === n - 1 ? " · 最新" : ""})`),
        width,
      ),
    );
    lines.push("");
    lines.push(truncateToWidth(th.fg("borderMuted", entry.title), width));
    lines.push(truncateToWidth(th.fg("borderMuted", "─".repeat(Math.min(width, 64))), width));

    // 内容（换行 + 滚动）
    const wrapped: string[] = [];
    for (const line of entry.body) {
      const w = wrapTextWithAnsi(line, Math.max(10, width - 4));
      wrapped.push(...w.map((l) => `  ${l}`));
    }
    const maxScroll = Math.max(0, wrapped.length - this.contentHeight);
    if (this.contentScroll > maxScroll) this.contentScroll = maxScroll;
    const slice = wrapped.slice(this.contentScroll, this.contentScroll + this.contentHeight);
    lines.push(...(slice.length ? slice : [th.fg("dim", "  (空)")]));
    lines.push("");

    const scrollInfo =
      wrapped.length > this.contentHeight
        ? ` · 内容 ${this.contentScroll + 1}-${Math.min(this.contentScroll + this.contentHeight, wrapped.length)}/${wrapped.length}`
        : "";
    lines.push(
      truncateToWidth(
        th.fg("dim", `↓/j 看更早  ↑/k 看更新  PgUp/PgDn 或 ←→ 滚动  q/Esc 退出${scrollInfo}`),
        width,
      ),
    );
    lines.push("");

    this.cachedWidth = width;
    this.cachedLines = lines;
    return lines;
  }

  invalidate(): void {
    this.cachedWidth = undefined;
    this.cachedLines = undefined;
  }
}

// ---------------------------------------------------------------------------
// 扩展入口
// ---------------------------------------------------------------------------
export default function (pi: ExtensionAPI) {
  // 注册统一配置：schema 写入中心 schema 文件，并自动注册 /provider-payload-config 命令。
  extConfig = registerConfig(pi, {
    key: EXT_KEY,
    schema: SCHEMA,
    description: "Provider 请求/响应/用量抓包日志",
  });

  // session_start 时从当前会话的日志文件校准请求对数（跨会话/重启保持准确）。
  pi.on("session_start", (_event, ctx) => {
    try {
      const file = logFile(sessionIdOf(ctx));
      entryCount = existsSync(file) ? (readFileSync(file, "utf8").match(/^===== REQ /gm) || []).length : 0;
    } catch {
      entryCount = 0;
    }
  });

  // 清空日志（当前会话的文件），避免长期积累。
  pi.registerCommand("payload-log-clear", {
    description: "清空当前会话的 provider 请求/响应日志（不可恢复）",
    handler: async (_args, ctx) => {
      try {
        const file = logFile(sessionIdOf(ctx));
        let removed = 0;
        if (existsSync(file)) {
          unlinkSync(file);
          removed++;
        }
        if (ctx.hasUI) ctx.ui.notify(`已清空 ${removed} 个日志文件（${logDir()}）`, "info");
        else console.log(`已清空 ${removed} 个日志文件`);
      } catch {
        if (ctx.hasUI) ctx.ui.notify(`清空失败：${logDir()}`, "error");
        else console.log(`清空失败：${logDir()}`);
      }
    },
  });

  // 查看日志：/payload-log [条目数]，默认从最新一条开始浏览。
  pi.registerCommand("payload-log", {
    description: "查看当前会话的 provider 请求/响应/用量日志（/payload-log [条目数]），默认从最新开始",
    handler: async (args, ctx) => {
      const file = logFile(sessionIdOf(ctx));

      let entries: LogEntry[];
      try {
        const maxEntries = Number(args) || 200;
        entries = parseLog(readFileSync(file, "utf8"));
        if (entries.length > maxEntries) entries = entries.slice(-maxEntries);
      } catch {
        if (ctx.hasUI) ctx.ui.notify(`日志不存在或不可读：${file}`, "warning");
        else console.log(`日志不存在或不可读：${file}`);
        return;
      }
      if (entries.length === 0) {
        if (ctx.hasUI) ctx.ui.notify("日志为空", "info");
        else console.log("日志为空");
        return;
      }

      if (ctx.mode === "tui") {
        await ctx.ui.custom<void>((tui, theme, _kb, done) => {
          const browser = new LogBrowser(entries, theme, () => done());
          return {
            render: (w) => browser.render(w),
            handleInput: (data) => {
              browser.handleInput(data);
              tui.requestRender();
            },
            invalidate: () => browser.invalidate(),
          };
        });
      } else if (ctx.hasUI) {
        await ctx.ui.select(`Provider Payload Log（共 ${entries.length} 条）`, entries.map((e) => e.title));
      } else {
        console.log(entries.map((e) => `${e.title}\n${e.body.join("\n")}`).join("\n\n"));
      }
    },
  });

  // 请求构造前：暂存请求（不立即写），并启动超时检测。
  pi.on("before_provider_request", (event, ctx) => {
    const item: PendingRequest = {
      sessionId: sessionIdOf(ctx),
      startedAt: Date.now(),
      model: ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "?",
      payload: event.payload,
      written: false,
    };
    pending.push(item);
    armTimeout(item);

    // 可选：用 return 改写请求体（而非仅记录）。
    // return { ...event.payload, temperature: 0 };
  });

  // 响应返回后：给最近的请求补上 status/headers；异常状态码立即落盘。
  pi.on("after_provider_response", (event, ctx) => {
    const item = latestUnwritten();
    if (!item) return;
    item.status = event.status;
    item.headers = event.headers as Record<string, string>;
    if (event.status >= 400) {
      const hdr = cur().mode === "verbose" ? ` | headers=${JSON.stringify(event.headers)}` : "";
      flush(item, [`!!!! ERROR @ ${now()} | status=${event.status}${hdr}`]);
    }
    // 2xx/3xx：等待 message_end 补上用量后一起落盘。
  });

  // 消息结束后：给最近的请求补上用量，一次性落盘（请求+响应+用量）。
  pi.on("message_end", (event, ctx) => {
    if (event.message.role !== "assistant") return;
    const item = latestUnwritten();
    if (!item) return;
    const usage = event.message.usage as UsageInfo | undefined;
    const stopReason = (event.message as { stopReason?: string }).stopReason;

    const tail: string[] = [];
    const verbose = cur().mode === "verbose";
    if (item.status !== undefined) {
      const hdr = verbose ? ` | headers=${JSON.stringify(item.headers)}` : "";
      tail.push(`---- RESP @ ${now()} | status=${item.status}${hdr}`);
    }
    tail.push(`.... USAGE @ ${now()} | ${usage ? formatUsage(usage) : `无用量数据 (stopReason=${stopReason ?? "?"})`}`);
    flush(item, tail);
  });

  // 会话结束：清理未完成的请求，落盘并取消定时器。
  pi.on("session_shutdown", () => {
    for (const item of pending) {
      if (item.written) continue;
      if (item.timer) clearTimeout(item.timer);
      flush(item, [`!!!! ABANDONED @ ${now()} | 会话结束，请求未完成`]);
    }
    pending.length = 0;
  });
}
