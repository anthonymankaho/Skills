---
name: codex-review-reply
description: Use when Anthony relays a request from Codex for a read-only review of a repo/commit/diff and says he will paste the result back - deliver the findings as a new Desktop file named CODEX_REVIEW_R<X>_YYYYMMDD_HHMM.md with a paste-ready prompt at the top, and keep the chat reply to a few lines.
---

# Codex Review Reply (`CODEX_REVIEW_R<X>_YYYYMMDD_HHMM.md`)

Anthony runs Codex, Claude Code and Qwen Code against the same folders and moves
work between them by pasting Desktop markdown files. When the ask is *"review this
read-only, don't edit/commit/push/deploy, paste the result back and I'll handle the
rest"*, the deliverable is a **review file**, not a chat answer.

## Filename

`CODEX_REVIEW_R<X>_YYYYMMDD_HHMM.md`, in the working directory Anthony is using
(usually the Desktop, which is OneDrive-synced — so **no credential values in it**).

- `<X>` = review **round** on the same workstream: `R1` first review, `R2` a
  re-review after the other agent changed code, `R3` next round. Increment it; do
  not reuse a number.
- Get the time, never guess: `echo %date% %time%` (cmd) → `20261103_1648`.
- **Always a new file.** Overwrite only when Anthony names the file. (Earlier files
  in this series used a dash, e.g. `CODEX_REVIEW_R2_20261103-1644.md` — leave those
  as they are; the underscore form is the going-forward convention.)

Pick the right prefix — the three are different jobs:

| File | Use for |
|---|---|
| `CODEX_REVIEW_R<X>_…` | results of a read-only review you performed |
| `CODEX_INSTRUCTION_…` | decisions Anthony made that Codex must apply to files/code |
| `CODEX_HANDOFF_…` | unfinished work passed over, esp. low usage quota (see `codex-handoff-on-low-usage`) |

## Required structure

1. **Header line** — date/time, mode (`read-only by Qwen Code — nothing edited,
   pushed, deployed, or executed`), repo path, and links to the prior review /
   instruction files in the series.
2. **`## Prompt for Codex ← paste-ready`** — a blockquote that stands alone: the
   verdict in one line, the highest-severity finding, the fix, and the holds
   ("no push/deploy until F6 + Step 4"). The receiving agent never sees this
   conversation, so it must be self-contained.
3. **Verdict table** — one row per reviewed area.
4. **Findings, ranked, with stable IDs** (`G1`, `G2`, … continuing whatever letter
   series is already in use so cross-references survive). Each with severity, the
   file/line that proves it, and a concrete fix.
5. **Scope** — explicitly split **Reviewed** vs **Not reviewed**, and
   **VERIFIED** (with the exact command and result) vs **UNVERIFIED**. Include
   anything you could not check *because it needed credentials or execution*.
6. **Still open** — carry forward the previous round's items with status, so
   nothing quietly disappears.
7. **Recommended order** — a single arrow-chained line.

## Rules that make the review trustworthy

- **Stay read-only.** No edits, commits, pushes, deploys, credential reads, relay
  starts, or test execution (`npm test` included) unless Anthony lifts it. State
  plainly that you did not reproduce the other agent's test results.
- **Re-verify current state before asserting it**: `git status -sb`, `git diff`,
  `git log --oneline -4` — another agent may have committed or dirtied the tree
  mid-task. Unfamiliar dirty files are theirs, not Anthony's.
- **Quantify severity with arithmetic**, not adjectives: e.g. *"worst bound
  65,536+512,400 = 68,448 tokens; 1,000,000 ÷ 68,448 ≈ 14.6 → 15 failures zero the
  month; at 7 s/bucket ≈ 105 s"* is what made the finding actionable.
- **Correct your own earlier claims** in the same file and re-stamp stale
  `VERIFIED` tags — a false verified claim is worse than an unknown. If you told
  them to change something and a later read disproves it, say so.
- **No secrets**: reference credential files by path + last-modified time only.
  Counts-only greps (`findstr ... | find /c /v ""`) for leak scans; note that
  `sk-` false-positives on CSS `mask-`.
- Prefer **cmd** built-ins; never run PowerShell without an explicit order.

## Chat reply

Three to six lines, bilingual (English + 繁體中文 — see `bilingual-replies`):
the file path, the headline verdict, the top finding with its number, and what is
blocked on Anthony. The detail belongs in the file, not in chat.
