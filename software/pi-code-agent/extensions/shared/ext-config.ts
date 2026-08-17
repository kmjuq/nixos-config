// ============================================================================
// ext-config.ts —— pi 扩展统一配置注册中心（共享库，非扩展本体）
// ----------------------------------------------------------------------------
// 为什么用磁盘文件汇总注册表？
//   实验确认：pi 对每个扩展文件独立打包加载，共享模块会被实例化多次，内存
//   单例不跨扩展共享。因此"注册 → 中心解析"必须通过磁盘文件协同。
//
// 三个文件分工：
//   ~/.pi/agent/pi-extensions.schema.json   运行时自动生成：各扩展注册的 schema
//   ~/.pi/agent/pi-extensions.default.json  Nix 管理的只读默认值（home-manager 链接）
//   ~/.pi/agent/pi-extensions.json          运行时可写：用户/命令修改的当前值
//
// 解析优先级（从高到低）：真实值文件 > 默认值文件 > schema 里声明的 default。
// 每个字段都会做类型/枚举校验，非法值回退到默认。
//
// 用法（扩展侧）：
//   import { registerConfig } from "./shared/ext-config";
//   const config = registerConfig(pi, {
//     key: "provider-payload",
//     description: "Provider 抓包日志",
//     schema: {
//       mode: { type: "enum", options: ["simple", "verbose"], default: "simple", description: "日志详细度" },
//     },
//   });
//   // 事件 handler 里每次调用 config.get()（不缓存），保证运行时切换即时生效
// ============================================================================
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { AutocompleteItem } from "@earendil-works/pi-tui";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";

// ---------------------------------------------------------------------------
// 类型定义
// ---------------------------------------------------------------------------
export type FieldType = "string" | "number" | "boolean" | "enum";

export interface ConfigField {
  type: FieldType;
  /** 默认值（类型必须匹配） */
  default: unknown;
  /** 人类可读描述，展示在 /cfg 和 /<key>-config 里 */
  description?: string;
  /** 仅 enum：可选值列表 */
  options?: string[];
  /** 仅 number：范围约束 */
  min?: number;
  max?: number;
}

export type ConfigSchema = Record<string, ConfigField>;

/** 解析后的配置值。字段缺失时已回填默认值。 */
export type ConfigValue = Record<string, string | number | boolean | undefined>;

export interface RegisteredSchema {
  key: string;
  description?: string;
  schema: ConfigSchema;
}

export interface ConfigAccessor {
  /** 扩展唯一标识 */
  key: string;
  /** 每次调用重新解析配置值文件，保证运行时修改即时生效 */
  get(): ConfigValue;
  /** 修改字段并写回真实值文件；字段不存在或校验失败返回 false */
  set(field: string, value: string | number | boolean): boolean;
}

export interface RegisterConfigOptions {
  /** 扩展唯一标识，如 "provider-payload" */
  key: string;
  /** 字段 schema 声明 */
  schema: ConfigSchema;
  /** 一句话描述，展示在 /cfg 里 */
  description?: string;
  /** 是否自动注册 /<key>-config 命令，默认 true */
  autoCommand?: boolean;
}

// ---------------------------------------------------------------------------
// 路径
// ---------------------------------------------------------------------------
function expandHome(p: string): string {
  if (p === "~") return homedir();
  if (p.startsWith("~/")) return join(homedir(), p.slice(2));
  return p;
}

function globalConfigDir(): string {
  return expandHome(process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent"));
}

export function schemaFile(): string {
  return join(globalConfigDir(), "pi-extensions.schema.json");
}
export function defaultValuesFile(): string {
  return join(globalConfigDir(), "pi-extensions.default.json");
}
export function valuesFile(): string {
  return join(globalConfigDir(), "pi-extensions.json");
}

// ---------------------------------------------------------------------------
// 底层文件 IO（全部容错，失败不抛异常）
// ---------------------------------------------------------------------------
function readJSON<T>(file: string): T | undefined {
  try {
    if (!existsSync(file)) return undefined;
    return JSON.parse(readFileSync(file, "utf8")) as T;
  } catch {
    return undefined;
  }
}

function writeJSON(file: string, data: unknown): boolean {
  try {
    mkdirSync(dirname(file), { recursive: true });
    writeFileSync(file, JSON.stringify(data, null, 2) + "\n", "utf8");
    return true;
  } catch {
    return false;
  }
}

// ---------------------------------------------------------------------------
// schema 注册（幂等写盘，只更新自己的 key，不碰别人的）
// ---------------------------------------------------------------------------
export function registerSchema(reg: RegisteredSchema): void {
  const file = schemaFile();
  const all = readJSON<Record<string, RegisteredSchema>>(file) ?? {};
  all[reg.key] = reg;
  writeJSON(file, all);
}

export function readAllSchemas(): Record<string, RegisteredSchema> {
  return readJSON<Record<string, RegisteredSchema>>(schemaFile()) ?? {};
}

// ---------------------------------------------------------------------------
// 字段校验
// ---------------------------------------------------------------------------
function validateValue(field: ConfigField, value: unknown): unknown {
  switch (field.type) {
    case "string":
      return typeof value === "string" ? value : field.default;
    case "number": {
      if (typeof value === "number" && !Number.isNaN(value)) {
        let v = value;
        if (field.min !== undefined) v = Math.max(v, field.min);
        if (field.max !== undefined) v = Math.min(v, field.max);
        return v;
      }
      return field.default;
    }
    case "boolean":
      return typeof value === "boolean" ? value : field.default;
    case "enum":
      return field.options?.includes(value as string) ? value : field.default;
    default:
      return field.default;
  }
}

// ---------------------------------------------------------------------------
// 中心解析：合并 真实值 > 默认值文件 > schema 默认，并逐字段校验
// ---------------------------------------------------------------------------
export function resolveConfig(key: string, schema: ConfigSchema): ConfigValue {
  const defaults: Record<string, unknown> = {};
  for (const [f, def] of Object.entries(schema)) defaults[f] = def.default;

  const real = (readJSON<Record<string, Record<string, unknown>>>(valuesFile()) ?? {})[key];
  const seed = (readJSON<Record<string, Record<string, unknown>>>(defaultValuesFile()) ?? {})[key];

  const merged: Record<string, unknown> = { ...defaults, ...seed, ...real };
  const out: ConfigValue = {};
  for (const [f, field] of Object.entries(schema)) {
    out[f] = validateValue(field, merged[f]) as string | number | boolean | undefined;
  }
  return out;
}

// ---------------------------------------------------------------------------
// 写入真实值（set）。字段不存在/校验失败返回 false。
// ---------------------------------------------------------------------------
export function writeConfigValue(
  key: string,
  field: string,
  value: unknown,
  schema: ConfigSchema,
): boolean {
  const fieldDef = schema[field];
  if (!fieldDef) return false;
  const validated = validateValue(fieldDef, value);
  const file = valuesFile();
  const all = readJSON<Record<string, Record<string, unknown>>>(file) ?? {};
  const section = { ...(all[key] ?? {}) };
  section[field] = validated;
  all[key] = section;
  return writeJSON(file, all);
}

// ---------------------------------------------------------------------------
// UI 输出辅助（TUI / RPC 用 notify，print / json 用 console）
// ---------------------------------------------------------------------------
export function notify(ctx: ExtensionContext, msg: string, level: "info" | "warning" | "error"): void {
  if (ctx.hasUI) ctx.ui.notify(msg, level);
  else console.log(`[ext-config] ${msg}`);
}

// ---------------------------------------------------------------------------
// 展示格式化
// ---------------------------------------------------------------------------
export function formatSection(key: string, reg: RegisteredSchema, values: ConfigValue): string {
  const lines = [`${key}${reg.description ? ` — ${reg.description}` : ""}`];
  for (const [f, field] of Object.entries(reg.schema)) {
    const v = values[f];
    let extra = "";
    if (field.type === "enum") extra = ` [${field.options?.join("|")}]`;
    lines.push(`  ${f} = ${JSON.stringify(v)}${extra}`);
    if (field.description) lines.push(`      ${field.description}`);
  }
  return lines.join("\n");
}

// ---------------------------------------------------------------------------
// 自动补全：<key>-config 命令用
// ---------------------------------------------------------------------------
export function fieldCompletions(reg: RegisteredSchema, prefix: string): AutocompleteItem[] | null {
  const items: AutocompleteItem[] = [];
  for (const [f, field] of Object.entries(reg.schema)) {
    if (!f.startsWith(prefix)) continue;
    items.push({ value: f, label: `${f} (${field.type})` });
  }
  return items.length > 0 ? items : null;
}

export function enumCompletions(field: ConfigField, prefix: string): AutocompleteItem[] | null {
  if (field.type !== "enum") return null;
  const items = (field.options ?? [])
    .filter((o) => o.startsWith(prefix))
    .map((o) => ({ value: o, label: o }));
  return items.length > 0 ? items : null;
}

export function boolCompletions(prefix: string): AutocompleteItem[] | null {
  const items = ["true", "false"].filter((o) => o.startsWith(prefix)).map((o) => ({ value: o, label: o }));
  return items.length > 0 ? items : null;
}

// ---------------------------------------------------------------------------
// 每个扩展的 /<key>-config 命令
//   /<key>-config                     → 查看该扩展全部配置
//   /<key>-config <field>             → 查看单个字段
//   /<key>-config <field> <value>     → 修改并写回
// ---------------------------------------------------------------------------
function registerConfigCommand(
  pi: ExtensionAPI,
  key: string,
  schema: ConfigSchema,
  description?: string,
): void {
  pi.registerCommand(`${key}-config`, {
    description: `查看/修改 ${key} 扩展配置（/${key}-config [字段] [值]）${description ? "：" + description : ""}`,
    getArgumentCompletions: (prefix: string): AutocompleteItem[] | null => {
      const parts = prefix.trim().split(/\s+/);
      const reg: RegisteredSchema = { key, schema };
      if (parts.length <= 1) {
        return fieldCompletions(reg, parts[0] ?? "");
      }
      const field = parts[0];
      const fieldDef = schema[field];
      if (!fieldDef) return null;
      const valuePrefix = parts.slice(1).join(" ") || "";
      if (fieldDef.type === "enum") return enumCompletions(fieldDef, valuePrefix);
      if (fieldDef.type === "boolean") return boolCompletions(valuePrefix);
      return null;
    },
    handler: async (args, ctx) => {
      const parts = (args ?? "").trim().split(/\s+/);
      const reg: RegisteredSchema = { key, schema };
      const values = resolveConfig(key, schema);

      // 无参：查看全部
      if (parts.length === 0 || parts[0] === "") {
        notify(ctx, formatSection(key, reg, values), "info");
        return;
      }
      const field = parts[0];
      const fieldDef = schema[field];
      if (!fieldDef) {
        notify(ctx, `未知字段 ${field}，可用：${Object.keys(schema).join(", ")}`, "error");
        return;
      }
      // 单字段：查看
      if (parts.length === 1) {
        notify(ctx, `${key}.${field} = ${JSON.stringify(values[field])} — ${fieldDef.description ?? fieldDef.type}`, "info");
        return;
      }
      // 两个以上：修改
      const raw = parts.slice(1).join(" ");
      let value: string | number | boolean = raw;
      if (fieldDef.type === "number") value = Number(raw);
      else if (fieldDef.type === "boolean") value = raw === "true";
      if (!writeConfigValue(key, field, value, schema)) {
        notify(ctx, `设置失败（校验未通过或写入失败）：${key}.${field}=${raw}`, "error");
        return;
      }
      const after = resolveConfig(key, schema);
      notify(ctx, `已设置 ${key}.${field} = ${JSON.stringify(after[field])}`, "info");
    },
  });
}

// ---------------------------------------------------------------------------
// 注册入口
// ---------------------------------------------------------------------------
export function registerConfig(pi: ExtensionAPI, opts: RegisterConfigOptions): ConfigAccessor {
  const { key, schema, description, autoCommand = true } = opts;
  registerSchema({ key, schema, description });
  if (autoCommand) registerConfigCommand(pi, key, schema, description);

  return {
    key,
    get: () => resolveConfig(key, schema),
    set: (field, value) => writeConfigValue(key, field, value, schema),
  };
}
