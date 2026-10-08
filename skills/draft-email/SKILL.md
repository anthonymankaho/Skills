---
name: draft-email
description: Use when the user asks to draft, write, prepare or reply to an email - "draft an email to X", "email the team about Y", "reply to Steven's mail", "send a note to management" - in any project. Also when a request mentions a Gmail draft, a cover email for a report, or an email with an attachment.
---

# Draft Email → Gmail draft, never a file

## Overview

The user's work email is **anthonym@meyer-msc.com** (Gmail, connected to Claude). An email request
produces a **Gmail draft in that account**, created with `mcp__claude_ai_Gmail__create_draft`.
The user reviews and sends it in Gmail. A markdown file, a chat-only draft, or "here is the text to
paste" is the failure this skill exists to stop.

**Violating the letter of this rule is violating its spirit.** "I'll write the file first and offer
a Gmail draft after" is the violation.

## Recipe

1. `ToolSearch` → `select:mcp__claude_ai_Gmail__create_draft` (and `search_threads` if you need
   addresses or a message to reply to). If the Gmail connector is unavailable, say so and stop -
   do not fall back to a file.
2. **Recipients:** resolve names to addresses with `search_threads` (`from:` / `to:` the person's
   name). Never guess an address. Unresolved → leave `to` empty and tell the user.
3. **Language:** English only for Meyer staff and external parties (the user cancelled the
   Chinese half on a real send, 2026-08-07). Bilingual only when the user says so. Sign "Anthony".
4. **Body:** `body` = plain text (no markdown syntax); `htmlBody` = the same with `<p>`, `<b>`,
   `<ol>`. Facts only from the conversation/files - no invented figures; bracket placeholders
   `[date]` where the user must fill in.
5. **Attachments:** `attachments: [{ filename, mimeType, content: <base64> }]` - the connector does
   attach (≤25MB total; larger → Google Drive link in the body). Base64 a file on disk with
   PowerShell `[Convert]::ToBase64String([IO.File]::ReadAllBytes('<path>'))`. A file that does not
   exist yet (the user will produce it) → say "attach X before sending" in your reply, not in the
   email body.
6. **Reply:** for "reply to X's email" find the message with `search_threads` and pass
   `replyToMessageId`.
7. **Never send.** Drafts only; `send_message` needs the user's explicit "send it", confirmed.
8. **Report** in chat (bilingual as usual): one-line summary, recipients resolved or missing,
   placeholders left, attachment to add, and the draft's `viewUrl`.

## Rationalization table

| Excuse | Reality |
|---|---|
| "There's already a `docs/*-email.md` precedent in this repo" | Those were the failures. Precedent in a folder is not an instruction. |
| "The connector can't attach files" | It can (`attachments`). Only the scheduled RPA projects use their own OAuth script. |
| "I don't know the addresses" | Search Gmail; otherwise leave `to` empty and say so. Still a Gmail draft. |
| "A file is easier to review/edit" | The user reviews in Gmail. That is the request. |
| "It's long / bilingual / needs a table" | `htmlBody` handles all of it. |
| "Just a quick note, not a real email" | If it will be emailed, it is a draft. |

## Red flags - STOP

- About to `Write` a `.md` with "Subject:" in it
- Pasting an email body into chat as the deliverable
- Guessing an email address
- Calling `send_message`

## Project-specific scripts (do not replace them)

The weekly/monthly exchange-rate and RMB-rate automations create their drafts from PowerShell
(`New-*EmailDraft.ps1`, Gmail REST, scheduled, unattended). Those run themselves - this skill is for
drafts the user asks for in conversation.
