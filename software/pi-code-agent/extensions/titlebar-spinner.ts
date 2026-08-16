/**
 * Titlebar Spinner Extension
 *
 * Shows a braille spinner animation in the terminal title while the agent is working.
 * Uses `ctx.ui.setTitle()` to update the terminal title via the extension API.
 *
 * Usage:
 *   pi --extension examples/extensions/titlebar-spinner.ts
 */

// ============================================================================
// 设计思路
// ----------------------------------------------------------------------------
// 本示例演示用 ctx.ui.setTitle() 在"agent 工作期间"把终端标题做成盲文旋转动画。agent_start 启动定时器，每 80ms 用
// BRAILLE_FRAMES 循环帧刷新标题（前缀旋转字符 + cwd/会话名）；agent_end 与 session_shutdown 都调 stopAnimation 复位标题
// 并清定时器。getBaseTitle 用 pi.getSessionName() 组合会话名与目录名作为静止标题。轻量、纯 UI 装饰。
// ============================================================================
import path from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const BRAILLE_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]; // 盲文旋转帧

function getBaseTitle(pi: ExtensionAPI): string {
	const cwd = path.basename(process.cwd());
	const session = pi.getSessionName();
	return session ? `π - ${session} - ${cwd}` : `π - ${cwd}`;
}

export default function (pi: ExtensionAPI) {
	let timer: ReturnType<typeof setInterval> | null = null;
	let frameIndex = 0; // 当前动画帧索引

	// 停止动画：清定时器、复位帧索引、恢复基础标题。
	function stopAnimation(ctx: ExtensionContext) {
		if (timer) {
			clearInterval(timer);
			timer = null;
		}
		frameIndex = 0;
		ctx.ui.setTitle(getBaseTitle(pi));
	}

	// 启动动画：先停旧的，再起定时器循环刷新标题。
	function startAnimation(ctx: ExtensionContext) {
		stopAnimation(ctx);
		timer = setInterval(() => {
			const frame = BRAILLE_FRAMES[frameIndex % BRAILLE_FRAMES.length];
			const cwd = path.basename(process.cwd());
			const session = pi.getSessionName();
			// 旋转帧 + cwd/会话名 拼成动态标题。
			const title = session ? `${frame} π - ${session} - ${cwd}` : `${frame} π - ${cwd}`;
			ctx.ui.setTitle(title);
			frameIndex++;
		}, 80);
	}

	// agent 启动：开始旋转动画。
	pi.on("agent_start", async (_event, ctx) => {
		startAnimation(ctx);
	});

	// agent 结束：停止动画并复位标题。
	pi.on("agent_end", async (_event, ctx) => {
		stopAnimation(ctx);
	});

	// 会话关闭：同样复位标题与定时器。
	pi.on("session_shutdown", async (_event, ctx) => {
		stopAnimation(ctx);
	});
}

