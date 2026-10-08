---
name: codex-handoff-on-low-usage
description: Use when the Claude Code 7-day (weekly) usage limit has less than 10% remaining, when the user says they are nearly out of Claude usage or quota, or when asked to hand unfinished work to Codex / write a Codex continuation prompt and progress summary. Also check at session start and after long tasks.
---

# Codex Handoff on Low 7-Day Usage

## Overview
When the 7-day quota is nearly spent, stop starting new work and write a **Codex handoff file**: a paste-ready prompt plus a 工作進度 (work progress) record, so Codex continues the unfinished work without re-discovery.

**Threshold:** 7-day **remaining < 10%** (used ≥ 90%). The user's wording "under 10%" is read as *remaining*; if they meant otherwise, pass `-ThresholdRemaining`.

## Step 1: Check usage
```
powershell -NoProfile -File C:/Users/User/.claude/skills/codex-handoff-on-low-usage/scripts/check-usage.ps1
```
Last line is `DECISION=HANDOFF`, `OK` or `UNKNOWN`.
- `OK` → carry on normally; say nothing about handoff.
- `UNKNOWN`, or `CACHE_AGE_MIN` > 30 near the threshold → ask the user to confirm via `/usage`.
- `HANDOFF` → do Step 2 now. Finish the current atomic step first; start nothing new.

The user can also invoke this explicitly at any usage level.

## Step 2: Write the handoff file
Path: `<project working directory>\CODEX_HANDOFF_<yyyyMMdd-HHmm>.md`. English prompt, with 工作進度 in Traditional Chinese beside each English progress line. Fill **every** section from the real session and files; use `git status`/`git diff --stat` where the folder is a repo.

| Section | Must contain |
|---|---|
| **Prompt for Codex** | Paste-ready: role, project, goal, then "continue from Next Step 1". Self-contained: Codex has none of this conversation. |
| **Goal / 目標** | What the user wants, one paragraph, plus acceptance criteria. |
| **Done / 已完成** | Each item tagged `VERIFIED` (with the command/check and result) or `UNVERIFIED`. |
| **Not finished / 未完成** | Ordered Next Steps, each with exact file paths, function/sheet/cell names, and the intended change. Step 1 must be doable immediately. |
| **工作進度** | Status per workstream: 完成 / 進行中 / 未開始 / 受阻, with % or stage. |
| **Files / 檔案** | Every file created, edited or relevant (absolute paths), with one-line role. Mark any half-edited file. |
| **Decisions & constraints / 決定與限制** | User decisions already made (don't re-ask), project rules (e.g. Builder/Auditor governance, hold/release decisions), things not to touch. |
| **Gotchas / 注意** | Failed approaches and why, known bugs, environment quirks, commands that need care. |
| **Open questions / 待確認** | Only what truly needs the user. |
| **Parallel-work warning** | Codex and Claude may both edit these folders: tell Codex to check for changes it did not make before commit/merge/overwrite. |

## Step 3: Tell the user
Brief reply (follow the project's bilingual rule): usage figures and reset time, the handoff file path, the 1-line Next Step 1, and that nothing was sent or run in Codex. Offer to open or trim it.

## Rules
- **No secrets.** Never copy tokens, passwords, `.env` or `.credentials.json` contents; reference the file path only.
- **Never claim done without evidence.** Anything not re-checked is `UNVERIFIED`.
- **Don't launch Codex or any command** from the handoff; the user pastes it.
- **Keep it small.** Drafting must cost little of the remaining quota: no new exploration beyond reading files already touched. No subagents.
- **Overwrite policy:** new timestamped file each time; never overwrite an earlier handoff.

## Red flags — you are rationalizing
| Thought | Reality |
|---|---|
| "I'll just finish the whole task, it's nearly done" | Quota may cut mid-edit. Finish the atomic step, then write the handoff. |
| "Done list can be approximate" | Codex will redo or skip work. Tag VERIFIED/UNVERIFIED. |
| "Codex can figure out the files" | It has no context. List absolute paths and the exact next change. |
| "Cache says OK so skip" | Check `CACHE_AGE_MIN`; stale cache near 90% → confirm with `/usage`. |

## Optional automation
A skill only fires when Claude reads it. For an automatic nudge, add a `UserPromptSubmit` hook (via `update-config`) that runs `check-usage.ps1` and prints a reminder when `DECISION=HANDOFF`. Not installed by default.
