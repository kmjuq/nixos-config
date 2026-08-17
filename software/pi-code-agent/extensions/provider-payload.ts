// ============================================================================
// 设计思路
// ----------------------------------------------------------------------------
// 本示例演示 before_provider_request / after_provider_response 两个钩子做"请求/响应抓包"。前者在请求体发往 LLM 前触发，
// 把 event.payload 写入 .pi/provider-payload.log；后者在收到响应后记录状态码与响应头。更有用的是：before_provider_request
// 可 return 一个新 payload 来改写请求（如注释里的 temperature: 0），而不只是记录。适合调试/审计发给模型的内容。
// ============================================================================
import { appendFileSync } from "node:fs";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  // 日志文件路径：<cwd>/.pi/provider-payload.log。
  const logFile = join(process.cwd(), ".pi", "provider-payload.log");

  // 请求构造前：把请求体追加写入日志。
  pi.on("before_provider_request", (event) => {
    appendFileSync(logFile, `${JSON.stringify(event.payload, null, 2)}\n\n`, "utf8");
    // 可选：用 return 改写请求体（而非仅记录）。
    // return { ...event.payload, temperature: 0 };
  });

  // 响应返回后：记录状态码与响应头。
  pi.on("after_provider_response", (event) => {
    appendFileSync(logFile, `[${event.status}] ${JSON.stringify(event.headers)}\n\n`, "utf8");
  });
}
