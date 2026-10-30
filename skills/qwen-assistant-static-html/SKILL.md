---
name: qwen-assistant-static-html
description: Use when adding a Qwen AI chat assistant to a STATIC single-file HTML tool opened via file:// (shared with colleagues, no web server, no user accounts) - browser-direct provider calls die on CORS, the API key must never ship inside a shared file, and the fix is a loopback Node relay. Triggers "Failed to fetch" from file://, CORS/OPTIONS blocks, preflight 401, thinking-block replies, chat text leaking into a "save file with data" copy. For hosted websites with auth backends use qwen-assistant-html instead.
---

# Qwen Assistant in a Static file:// HTML Tool

## Overview

Core principle: **a static page cannot safely or even successfully call the
provider itself** - from `file://` the browser sends `Origin: null` and any
gateway without `Access-Control-Allow-Origin` headers blocks the response, and
any key placed in the file is public as soon as it's shared. The architecture
is therefore a tiny **loopback Node relay** that holds the credential, answers
the CORS, and enforces every limit server-side; the HTML panel stays secret-free
and degrades gracefully to "offline".

## Step 1 - Probe the gateway BEFORE choosing any architecture

Never assume; run these three Node fetches first (Node ignores CORS, the
browser never will):

1. `POST {base}/v1/messages` with `Origin: null` - record status and whether ANY
   `access-control-*` response header exists. No ACAO ⇒ browser-direct is
   impossible, full stop.
2. `OPTIONS` preflight to the same URL (Chrome always preflights
   JSON+custom-header POSTs) - some gateways answer **401 even to preflight**,
   which is fine for you but fatal for direct browser use.
3. Probe `/compatible-mode/v1/chat/completions` (OpenAI-style) on the same
   host - the model name may come from a different config file
   (check `.claude/settings-qwen.json`; beware UTF-16 BOM on Windows configs).
   Then call it once for real and inspect the JSON: does `content[]` contain
   **`thinking` blocks** before the `text` blocks? Does it return `usage` and
   `stop_reason`?

## Step 2 - The relay (`relay.example.mjs`, zero dependencies, Node >= 18)

- Bind `server.listen(PORT, '127.0.0.1')` - **loopback only**. Do not expose on
  the LAN (firewall rules, other machines) without the user explicitly asking;
  colleagues without the relay get the panel's offline state, which is the
  designed behaviour.
- Config (`proxy.config.json` next to the script) holds `baseUrl/token/model`.
  **Place the whole relay folder OUTSIDE any cloud-synced directory** -
  `Desktop` is a live leak path here (Desktop → OneDrive → GitHub). Reuse an
  existing bearer by copying it in a script that never prints it.
- ONE `CAPS` block used by both validation and request construction (they can
  never drift): body bytes, message chars, history turns, per-item chars,
  context chars, `replyTokens` sent as provider `max_tokens` **on every
  request**, upstream timeout via `AbortSignal.timeout`, `redirect:'error'`,
  upstream response byte cap.
- Budget the prompt: estimate tokens (chars / ~2.4 for CJK+Latin mix) and
  reject over-budget BEFORE calling the provider, telling the user to clear the
  chat. Never trust silent provider truncation.
- Quota per username per calendar month from the provider `usage`
  (input+output tokens), persisted to `quota.json`; warn at ≥ 80%, fail closed
  at 100%. A per-user min-interval stops a stuck panel from draining quota.
- Parse `content[]` yourself: join only `type==='text'` blocks;
  `stop_reason==='max_tokens'` ⇒ mark the reply truncated.
- CORS: `ACAO *`, `Allow-Headers content-type`, `POST/OPTIONS`, and answer
  OPTIONS with 204 (the browser needs YOUR CORS, not the gateway's).
- Never log prompts/replies/bodies - metadata lines only; map upstream 401/429/
  5xx to bounded user-safe messages; log nothing sensitive.

## Step 3 - The panel (app-side hygiene)

- Render all model text with `textContent` (never `innerHTML`).
- History lives in memory only - never localStorage.
- Context = a small **allowlisted projection** (settings, counts - never
  record contents/amounts/passwords), and the panel states in one line exactly
  what leaves the machine.
- If the app can clone-and-save itself ("save file with data" style): tag the
  chat nodes `data-ai-exclude` and strip them in the serializer - or the first
  shared copy carries your conversation. Reset the panel on logout too.
- Health-probe `/health` when opening; offline ⇒ status line + retry, the rest
  of the app untouched. Escape/overlay close, focus the input.
- Auto-start (scheduled task, Startup folder) is a persistence change - only
  with the user's explicit yes; otherwise ship `start-proxy.bat`.

## Verification (all four, with a real browser)

(a) grep the shared file for the token prefix - zero hits; (b) open via
`file://` in Chromium (Playwright + cached `ms-playwright\chromium_*\
chrome-headless-shell-win64\chrome-headless-shell.exe`) and get a real reply;
(c) kill the relay → friendly offline state, no crash; (d) use the app's
save-copy → reopen → panel empty. Bonus: mock an `<img onerror>` reply →
renders inert.

## Common mistakes

| Mistake | Consequence |
|---|---|
| Skipping the CORS probe | "works in curl, 'Failed to fetch' in the browser" - days lost |
| Key in the HTML for simplicity | leaks with the next shared copy |
| Caps only in the browser | first curious user bypasses all of them |
| `history` persisted to localStorage | colleagues inherit each other's chats |
| `innerHTML` for "markdown" | XSS from the model output into the app |
| LAN-exposing the relay unprompted | firewall + key-hosting service on a desk PC nobody approved |

Real-world instances: `MPL_System.html` + `C:\Users\User\.mpl-qwen\` (2026-10-30); the
Global Purchase Report war-room dashboard (`3D Earth Dashboard\Global_Purchase_3D_WarRoom_TEMP.html`)
added 2026-10-30 **sharing the same relay process on port 8765 instead of getting its own** -
one relay can serve several file:// tools: keep the per-app identity in the first line of the
panel's DATA CONTEXT (`CURRENT APP: ...`), not in a second proxy. Per-app `quota.json` user
keys (e.g. `gpr-selftest`) still isolate usage records, and a second `.gpr-qwen` copy was
deliberately NOT created - fewer moving parts, one bearer, one process to restart.
