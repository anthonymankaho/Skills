---
tags: [skill, superpowers, process, git]
---

# Skill: Using Git Worktrees (Superpowers)

Use before starting feature work that needs isolation from the current workspace, or before executing an implementation plan. Detects whether you're already in an isolated workspace first; prefers a harness-native worktree tool over manual `git worktree` commands (bypassing a native tool creates phantom state the harness can't manage); falls back to `.worktrees/` (verified `.gitignore`d) only when no native tool exists. Runs project setup and a clean-baseline test pass before reporting ready.

## Full detail (the actual skill file, not just this summary)
`C:\Users\User\.claude\plugins\cache\claude-plugins-official\superpowers\6.3.0\skills\using-git-worktrees\SKILL.md`
