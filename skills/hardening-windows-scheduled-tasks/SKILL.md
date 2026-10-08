---
name: hardening-windows-scheduled-tasks
description: Use when creating or reviewing a Windows Scheduled Task for any unattended automation workflow (RPA rebuild, sync script, report job) - especially when a task only fires if the PC happens to be on at the exact trigger time, or after noticing a scheduled automation silently didn't run with no error logged.
---

# Hardening Windows Scheduled Tasks

## Overview

Windows Scheduled Tasks silently skip a missed trigger by default: if the PC is
off or asleep at the scheduled time, nothing runs and no error appears anywhere.
Every unattended automation task for this user's projects (RPA rebuilds, sync
jobs, report generators) must explicitly set `StartWhenAvailable = True` so a
missed run catches up as soon as the machine is next on.

## When to Use

- Creating any new Scheduled Task meant to run unattended (daily/weekly report
  rebuild, file sync, RPA kickoff)
- Reviewing an existing task where automation "just didn't run" one day with
  no error trail
- Any time `schtasks /Create` is used directly - see gotcha below

## The Gotcha: schtasks.exe has no flag for this

`schtasks /Create` has no `/`-flag for "start when available" - it can only be
set via the Task Scheduler UI or the PowerShell `ScheduledTasks` module. A task
registered with plain `schtasks /Create` defaults to `StartWhenAvailable =
False` with no warning. Patch it in immediately after creation:

```powershell
$t = Get-ScheduledTask -TaskName "<TaskName>"
$t.Settings.StartWhenAvailable = $true
Set-ScheduledTask -TaskName "<TaskName>" -Settings $t.Settings
```

Or set it from the start with `Register-ScheduledTask` instead of `schtasks`:

```powershell
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable
Register-ScheduledTask -TaskName "<TaskName>" -Action $action -Trigger $trigger -Settings $settings
```

## Quick Reference

| Setting | Recommended | Why |
|---|---|---|
| `StartWhenAvailable` | `True` | Catch up later the same day / at next boot if the trigger was missed |
| `WakeToRun` | Usually `False` | Only enable if the task must run even through sleep (rare for a desktop that's normally on) |

Always verify after creation, don't assume:

```powershell
(Get-ScheduledTask -TaskName "<TaskName>").Settings | Select-Object StartWhenAvailable, WakeToRun
```

## Common Mistake

Registering via `schtasks /Create` and treating that as the final state. The
task silently defaults to `StartWhenAvailable = False`, so a missed 13:00 run
(PC off/asleep) is dropped for the day with zero indication anything was
skipped - it just looks like the automation "didn't happen."

## Real-World Case

Found in the Desktop-to-OneDrive daily sync automation: the task was created
via `schtasks /Create` for a 13:00 daily run. Had to go back and flip
`StartWhenAvailable` via `Get-ScheduledTask`/`Set-ScheduledTask` after the user
asked whether simply turning the PC on (vs. explicitly waking it from sleep)
was enough to trigger the sync. A baseline test of a fresh agent drafting a
similar task independently reproduced the same inconsistency: it added
`-StartWhenAvailable` when presenting the PowerShell-cmdlet form, but silently
omitted the equivalent when its primary answer used raw `schtasks /Create`.
