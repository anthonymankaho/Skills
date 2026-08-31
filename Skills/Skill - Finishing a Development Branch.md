---
tags: [skill, superpowers, process, git]
---

# Skill: Finishing a Development Branch (Superpowers)

Use once implementation is complete and all tests pass, to decide how to integrate the work. Verifies the full test suite is green, detects the git/worktree environment, then presents a fixed menu (merge locally / push + PR / keep as-is, or a reduced 2-option menu on detached HEAD) and waits for the human's explicit choice — never assumes intent, and only discards work on an explicit typed "discard" confirmation. Cleans up worktrees it owns (under `.worktrees/`/`worktrees/`) after a successful merge or confirmed discard.

## Full detail (the actual skill file, not just this summary)
`C:\Users\User\.claude\plugins\cache\claude-plugins-official\superpowers\6.3.0\skills\finishing-a-development-branch\SKILL.md`
