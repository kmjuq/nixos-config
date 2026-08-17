// ============================================================================
// ext-config-center.ts —— pi 扩展统一配置中心
// ----------------------------------------------------------------------------
// 提供一个统一的 /cfg 命令来管理【所有】注册了 schema 的扩展配置：
//   /cfg                                   → 列出所有扩展及其当前配置
//   /cfg <key>                             → 查看某个扩展的配置
//   /cfg <key> <field>                     → 查看单个字段
//   /cfg <key> <field> <value>             → 修改并写回（TAB 可补全 key/字段/枚举值）
//
// schema 由各扩展在启动时注册到
//   ~/.pi/agent/pi-extensions.schema.json
// 本命令运行时实时读取，扩展增删/改 schema 后无需改动本文件。
// ============================================================================
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { AutocompleteItem } from "@earendil-works/pi-tui";
import {
  boolCompletions,
  enumCompletions,
  formatSection,
  notify,
  readAllSchemas,
  resolveConfig,
  writeConfigValue,
} from "./shared/ext-config";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("cfg", {
    description: "统一查看/修改所有扩展配置（/cfg [key] [字段] [值]）",
    getArgumentCompletions: (prefix: string): AutocompleteItem[] | null => {
      const parts = prefix.trim().split(/\s+/);
      const regs = readAllSchemas();

      // 第一段：扩展 key
      if (parts.length <= 1) {
        const items = Object.keys(regs)
          .filter((k) => k.startsWith(parts[0] ?? ""))
          .map((k) => ({ value: k, label: k }));
        return items.length > 0 ? items : null;
      }
      const reg = regs[parts[0]];
      if (!reg) return null;

      // 第二段：字段名
      if (parts.length === 2) {
        const items = Object.keys(reg.schema)
          .filter((f) => f.startsWith(parts[1]))
          .map((f) => ({ value: f, label: `${f} (${reg.schema[f].type})` }));
        return items.length > 0 ? items : null;
      }

      // 第三段：字段值（enum / boolean）
      const field = reg.schema[parts[1]];
      if (!field) return null;
      const valuePrefix = parts.slice(2).join(" ") || "";
      if (field.type === "enum") return enumCompletions(field, valuePrefix);
      if (field.type === "boolean") return boolCompletions(valuePrefix);
      return null;
    },
    handler: async (args, ctx) => {
      const parts = (args ?? "").trim().split(/\s+/);
      const regs = readAllSchemas();

      // 无参：列出所有扩展配置
      if (parts.length === 0 || parts[0] === "") {
        const keys = Object.keys(regs);
        if (keys.length === 0) {
          notify(ctx, "暂无扩展注册配置（还没有扩展调用 registerConfig）", "warning");
          return;
        }
        const blocks = keys.map((k) => formatSection(k, regs[k], resolveConfig(k, regs[k].schema)));
        notify(ctx, blocks.join("\n\n"), "info");
        return;
      }

      const key = parts[0];
      const reg = regs[key];
      if (!reg) {
        notify(ctx, `未知扩展 key：${key}。已注册：${Object.keys(regs).join(", ") || "(无)"}`, "error");
        return;
      }

      // 单 key：查看该扩展全部
      if (parts.length === 1) {
        notify(ctx, formatSection(key, reg, resolveConfig(key, reg.schema)), "info");
        return;
      }

      const field = parts[1];
      const fieldDef = reg.schema[field];
      if (!fieldDef) {
        notify(ctx, `未知字段 ${key}.${field}，可用：${Object.keys(reg.schema).join(", ")}`, "error");
        return;
      }

      // key + field：查看单字段
      if (parts.length === 2) {
        const v = resolveConfig(key, reg.schema)[field];
        notify(ctx, `${key}.${field} = ${JSON.stringify(v)} — ${fieldDef.description ?? fieldDef.type}`, "info");
        return;
      }

      // key + field + value：修改写回
      const raw = parts.slice(2).join(" ");
      let value: string | number | boolean = raw;
      if (fieldDef.type === "number") value = Number(raw);
      else if (fieldDef.type === "boolean") value = raw === "true";
      if (!writeConfigValue(key, field, value, reg.schema)) {
        notify(ctx, `设置失败（校验未通过或写入失败）：${key}.${field}=${raw}`, "error");
        return;
      }
      const after = resolveConfig(key, reg.schema)[field];
      notify(ctx, `已设置 ${key}.${field} = ${JSON.stringify(after)}`, "info");
    },
  });
}
