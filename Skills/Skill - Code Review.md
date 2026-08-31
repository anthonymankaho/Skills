---
tags: [skill, builtin, code-review]
---

# Skill: Code Review

Reviews the current diff, or a given PR number/branch/path target, for correctness bugs and reuse/simplification/efficiency cleanups at a chosen effort level (low/medium: fewer, high-confidence findings; high→max: broader coverage, may include uncertain findings). With no level given, reuses the last-used level. Supports `--comment` to post findings as inline PR comments, or `--fix` to apply findings to the working tree after review. Compare with [[Skill - Simplify|simplify]] (quality-only, no bug hunt) and [[Skill - Security Review|security-review]] (security-only).

## Full detail
Built into Claude Code — no separate SKILL.md on disk; invoked via the `code-review` skill name.
