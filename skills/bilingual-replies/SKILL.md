---
name: bilingual-replies
description: Use at the start of every response in this project, regardless of topic - all replies must be written in both English and Traditional Chinese (繁體中文), not one or the other.
---

# Bilingual Replies (English + Traditional Chinese)

## Overview

The user requires every reply — not just ones about a specific project — to be
written in **both English and Traditional Chinese (繁體中文)**, never English-only
or Chinese-only. This applies regardless of the language the user writes in for
their own message.

## How to apply

- Every user-facing reply must carry both languages. Common patterns that work well:
  - A short English line followed by its Traditional Chinese equivalent (or vice versa).
  - A bilingual table (English header / Chinese header, or one column each).
  - Bilingual bullet points, pairing each English point with its Chinese counterpart.
- Use **Traditional Chinese** (繁體中文), not Simplified Chinese (简体中文).
- Code, file paths, commands, and identifiers stay as-is (untranslated) — only the
  surrounding prose needs both languages.
- This applies to substantive replies. Trivial tool-call narration (a single
  sentence stating what you're about to do) doesn't need to be duplicated in both
  languages every time, but the actual answer/explanation/summary given to the user does.

## AskUserQuestion (clarifying questions)

Unlike prose replies (bilingual, both languages), the `AskUserQuestion` tool's
own content — the `question`, `header`, and each option's `label`/`description`
— must be written in **Traditional Chinese only**, not bilingual. The compact
UI doesn't have room for both languages per option, and the user reads these
directly. Keep any surrounding chat text (before/after the tool call) to the
normal bilingual rule above; only the tool call's own fields are Chinese-only.

## Why

Explicit standing instruction from the user, given independently of any single
project — treat it as a default posture for this working relationship, not a
one-off for whichever task prompted it.
