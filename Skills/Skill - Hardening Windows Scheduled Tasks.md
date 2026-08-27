---
tags: [skill, windows, scheduled-task]
---

# Skill: Hardening Windows Scheduled Tasks

Always set `StartWhenAvailable=True` on unattended scheduled tasks — the `schtasks` CLI has no direct flag for it, so it's easy to forget and end up with a task that silently never runs if the machine was off/asleep at the scheduled time.

## Used by
- [[Desktop-OneDrive Auto Sync]] — the daily 13:00 sync task.

## Full detail
`C:\Users\User\.claude\projects\c--Users-User-Desktop\memory\reference_hardening_windows_scheduled_tasks_skill.md`
