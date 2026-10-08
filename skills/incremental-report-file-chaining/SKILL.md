---
name: incremental-report-file-chaining
description: Use when a script incrementally updates a periodic report or data file across multiple runs (e.g. PowerShell rebuilds of RPA/UiPath processes producing dated snapshot files) - especially when data mysteriously vanishes or regresses between two consecutive runs, or when a script picks its base/template file by comparing timestamps across several candidate files.
---

# Incremental Report File Chaining

## Overview

When a script appends new data to some prior file each run and saves a new dated
snapshot, don't pick the "base" file by comparing timestamps across multiple candidate
locations (e.g. "newest file in the upstream/production folder" vs. "newest file this
script itself last produced"). That heuristic silently breaks the moment the upstream
process goes stale while your script is run repeatedly for testing - every run rebuilds
from the same stale base, and any data outside both the base and the current fetch
window vanishes with no error thrown.

## When to Use

- Rebuilding a periodic (weekly/monthly) RPA process in PowerShell/Python/etc. that
  mirrors an existing dated-snapshot naming convention (e.g. `Report_YYYYMMDD.xlsx`)
- A script decides its "template"/"base" input by sorting multiple candidate files by
  `LastWriteTime` across different folders
- Data appears to vanish, regress, or have gaps between two consecutive runs of an
  incremental-update script
- A "fetch last N days" step feeds into a file meant to accumulate history over time

## Core Pattern

**Don't:** guess the base file via timestamp comparison across folders.

```powershell
# Fragile - silently wrong if the upstream folder goes stale
$best = @($productionFile, $ownPriorOutput) | Sort-Object LastWriteTime -Descending | Select-Object -First 1
```

**Do:** maintain one persistent working file that every run reads and writes in place.
Only snapshot a dated, immutable copy at the actual business checkpoint (e.g. when the
report is emailed/finalized) - not on every intermediate run.

```powershell
# Deterministic - only one candidate, no guessing
$working = "Report_TEMP.xlsx"
# ... update $working in place each run ...
# At send-time only:
Copy-Item $working "Report_$(Get-Date -Format yyyyMMdd).xlsx"
```

## Related sub-pattern: don't truncate date-fetch windows to a fixed week

A "fetch last N days" step should span every date actually returned by the source
(earliest to latest), not truncate to one fixed calendar week anchored on the earliest
date. A moving N-day window run on different weekdays can straddle a week boundary
(e.g. Thu/Fri of last week + Mon-Wed of this week) - anchoring to a single week silently
drops whichever dates fall outside it.

Both mistakes combine to cause silent data loss with no error thrown - the kind of bug
only caught by manually diffing two output files side by side.

## Trade-off to know

A single continuously-overwritten working file loses the "snapshot per run" audit trail
that's useful for debugging (comparing today's run against yesterday's). If you need
that, keep dated snapshots at every run instead of only at the business checkpoint - but
then you must get the base-selection logic right, which is the whole problem this
pattern avoids. Pick one deliberately; don't default to timestamp-guessing as a middle
ground.

## Real-world case

Found in a PowerShell rebuild of a weekly UiPath exchange-rate report: the real UiPath
process stayed stale while the rebuild was tested across several days, so it kept
rebuilding from the same stale base each run; combined with a "fetch last 7 days" step
anchored to one fixed week, three days of data silently vanished between two runs.
Caught only because both dated outputs still existed to compare.

Independently corroborated in the Global Purchase Report PowerShell rebuild: after
hitting a same-filename collision bug from picking the "latest dated snapshot" as a
template, that project separately arrived at the same fix - a fixed, undated template
file instead.
