---
tags: [skill, superpowers, process, agents, planning]
---

# Skill: Subagent-Driven Development (Superpowers)

Use to execute an implementation plan's independent tasks within the current session: fresh implementer subagent per task, a task review (spec compliance + code quality) after each with a bounded fix loop (5 rounds max, then adjudicate), and one broad whole-branch review at the end on the most capable model. Runs continuously without check-ins — only irreversible/destructive actions, security-sensitive actions, shared-branch side effects, or a fundamentally broken plan stop it. Progress is tracked in a git-ignored ledger (`.superpowers/sdd/<plan>/progress.md`) that survives context compaction. Ends via [[Skill - Finishing a Development Branch|finishing-a-development-branch]].

## Full detail (the actual skill file, not just this summary)
`C:\Users\User\.claude\plugins\cache\claude-plugins-official\superpowers\6.3.0\skills\subagent-driven-development\SKILL.md`
