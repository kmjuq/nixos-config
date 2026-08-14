import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { AutocompleteProvider } from "@earendil-works/pi-tui";
import { join, resolve } from "node:path";
import { homedir } from "node:os";
import { existsSync } from "node:fs";

// ---------------------------------------------------------------------------
// "#" path references
//
// Like "@file" but instead of inlining the file content, a "#path" token is
// replaced with the ABSOLUTE path — but ONLY in the text that is sent to the
// model.
//
//  - Typing "#" opens a fuzzy file/directory completer (same fd search as "@")
//    and inserts "#relative/path" (or #"path with spaces").
//  - The TUI transcript keeps showing the short "#path" token; a display-only
//    markdown transformer highlights those tokens (inline-code style).
//  - The `context` event rewrites "#path" to the absolute path in the deep
//    copy that goes to the model, so the stored message and the transcript
//    are untouched.
// ---------------------------------------------------------------------------

// Matches a "#" token at the start of the line or after a delimiter
// (whitespace, quotes, = ( [ { , ; :):
//   #foo, #src/bar, #"my file.ts", #"my file" (open quote, unclosed)
const HASH_PREFIX_RE = /(?:^|[\s"'=(\[{,;:])(#(?:"(?:[^"\\]|\\.)*"?|[^\s#]*))$/;

function extractHashToken(beforeCursor: string): { prefix: string; query: string } | null {
  const m = beforeCursor.match(HASH_PREFIX_RE);
  if (!m) return null;
  const prefix = m[1];
  let query = prefix.slice(1);
  if (query.startsWith('"')) {
    query = query.slice(1);
    if (query.endsWith('"')) query = query.slice(0, -1);
    query = query.replace(/\\(["\\])/g, "$1");
  }
  return { prefix, query };
}

function createHashAutocompleteProvider(
  current: AutocompleteProvider,
): AutocompleteProvider {
  return {
    async getSuggestions(lines, cursorLine, cursorCol, options) {
      const beforeCursor = (lines[cursorLine] ?? "").slice(0, cursorCol);
      const token = extractHashToken(beforeCursor);
      if (!token) {
        return current.getSuggestions(lines, cursorLine, cursorCol, options);
      }

      // Reuse pi's own built-in "@" fuzzy file search instead of reimplementing
      // it: feed the base provider a fake one-line buffer where the "#" token
      // is rewritten as "@", then remap the returned values back to "#..."
      // form. This gets pi's exact fd search, src/foo scoping, ranking and
      // quoting for free.
      const query = token.query;
      const fakeLines = ["@" + query];
      const result = await current.getSuggestions(fakeLines, 0, fakeLines[0].length, options);
      if (!result || options.signal.aborted) {
        return null;
      }

      return {
        prefix: token.prefix,
        items: result.items.map((item) => ({
          ...item,
          value: "#" + item.value.slice(1),
        })),
      };
    },

    applyCompletion(lines, cursorLine, cursorCol, item, prefix) {
      return current.applyCompletion(lines, cursorLine, cursorCol, item, prefix);
    },

    shouldTriggerFileCompletion(lines, cursorLine, cursorCol) {
      return current.shouldTriggerFileCompletion?.(lines, cursorLine, cursorCol) ?? true;
    },
  };
}

// Match #"quoted path" or #unquoted/path. The token must start at the line
// start or after a delimiter (whitespace, quotes, = ( [ { , ; :), so markdown
// headings ("# Title") and URL fragments ("foo#bar") are left alone.
const HASH_TOKEN_RE = /(^|[\s"'=(\[{,;:])(#"(?:[^"\\]|\\.)*"|#[^\s#]+)/g;
const TRAILING_PUNCT_RE = /[),.;:!?\]}]+$/;

// Resolve a "#path" token to an absolute path. Returns null when the path does
// not exist. Trailing sentence punctuation (e.g. "check #foo.ts,") is trimmed
// from the path and returned separately so it is preserved in the message.
function resolveHashPath(
  raw: string,
  cwd: string,
): { abs: string; suffix: string } | null {
  let p = raw;
  if (p === "~") p = homedir();
  else if (p.startsWith("~/")) p = join(homedir(), p.slice(2));

  let abs = resolve(cwd, p);
  if (existsSync(abs)) return { abs, suffix: "" };

  const m = p.match(TRAILING_PUNCT_RE);
  if (m) {
    const suffix = m[0];
    const core = p.slice(0, p.length - suffix.length);
    if (!core) return null;
    abs = resolve(cwd, core);
    if (existsSync(abs)) return { abs, suffix };
  }
  return null;
}

function parseHashToken(token: string): { path: string } {
  let path = token.slice(1);
  if (path.startsWith('"') && path.endsWith('"')) {
    path = path.slice(1, -1).replace(/\\(["\\])/g, "$1");
  }
  return { path };
}

function replaceHashPaths(text: string, cwd: string): string {
  return text.replace(HASH_TOKEN_RE, (full, leading, token) => {
    const { path } = parseHashToken(token);
    const resolved = resolveHashPath(path, cwd);
    return resolved ? leading + resolved.abs + resolved.suffix : full;
  });
}

// Display-only: wrap "#path" tokens that resolve to an existing path in
// inline-code backticks so they stand out in the rendered user message. Keep
// sentence punctuation (e.g. the "," in "#a.ts,") outside the code span,
// mirroring what the model-side replacement does.
function highlightHashPaths(markdown: string, cwd: string): string {
  return markdown.replace(HASH_TOKEN_RE, (full, leading, token) => {
    const { path } = parseHashToken(token);
    const resolved = resolveHashPath(path, cwd);
    if (!resolved) return full;

    const isQuoted = token[1] === '"';
    if (isQuoted) {
      // Quoted token: wrap it as-is; any punctuation is inside the quotes.
      return `${leading}\`${token}\``;
    }
    const inner = resolved.suffix
      ? token.slice(0, token.length - resolved.suffix.length)
      : token;
    return `${leading}\`${inner}\`${resolved.suffix}`;
  });
}

// The cwd of the current session, captured in session_start and used by the
// display-only markdown transformer (which is not bound to a session ctx).
let currentCwd: string | undefined;

export default function (pi: ExtensionAPI) {
  // React to events
  pi.on("session_start", (_event, ctx) => {
    currentCwd = ctx.cwd;
    ctx.ui.notify("hash-path extension loaded!", "info");

    // Register "#" file-path autocomplete (fuzzy search like "@").
    ctx.ui.addAutocompleteProvider((current) => ({
      triggerCharacters: ["#"],
      ...createHashAutocompleteProvider(current),
    }));
  });

  // Before every LLM call, rewrite "#path" references in user messages to
  // absolute paths. `event.messages` is a deep copy, so only the text sent to
  // the model changes; the stored message and TUI transcript keep "#path".
  pi.on("context", (event, ctx) => {
    let changed = false;
    for (const m of event.messages) {
      if (m.role !== "user") continue;
      const content = m.content;
      if (typeof content === "string") {
        const text = replaceHashPaths(content, ctx.cwd);
        if (text !== content) {
          (m as { content: unknown }).content = text;
          changed = true;
        }
      } else if (Array.isArray(content)) {
        for (const part of content) {
          if (part?.type === "text") {
            const text = replaceHashPaths(part.text, ctx.cwd);
            if (text !== part.text) {
              part.text = text;
              changed = true;
            }
          }
        }
      }
    }
    if (!changed) return undefined;
    return { messages: event.messages };
  });

  // Display-only highlighting of "#path" tokens in user messages. This does
  // not affect what is sent to the model.
  pi.registerMarkdownTransformer((markdown, { messageType, isStreaming }) => {
    if (messageType !== "user" || isStreaming) return markdown;
    return highlightHashPaths(markdown, currentCwd ?? process.cwd());
  });

}
