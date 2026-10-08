---
name: mms-login
description: Use when logging into or pulling data from the Meyer Management System (MMS) portal (portal.meyer-mhk.com) - handles the email+password step plus MMS's mandatory 6-digit email OTP step. Also use when building any automation that reads Global Design/WebSpec, Product Catalogue, Finance, or 3 Year Vision data from MMS.
---

# MMS Login (portal.meyer-mhk.com)

## Overview

MMS ("Meyer Management System") requires two steps to log in: email+password,
then a mandatory 6-digit OTP emailed by `itsupport@meyer-msc.com` to the
account's own inbox. No browser/Playwright is needed - the whole flow is plain
HTTP (ASP.NET MVC forms + one JSON endpoint), scripted in PowerShell via
`Invoke-WebRequest -SessionVariable`.

## When to Use

- Any request to log into MMS, or scrape/export data from it (SKU specs, Part
  Master, Finance, Product Catalogue, 3 Year Vision, etc.)
- Building a new scheduled/unattended MMS automation
- Symptom: hitting `portal.meyer-mhk.com/MMS/Account/Login`, or an "Invalid
  login Password" / "Input One-time Password Here" chat widget

## Credentials

Stored DPAPI-encrypted (current Windows user+machine only) at
`credentials\mms_credentials.dat` in this skill folder - **never** commit or
sync this file, and never ask the user to paste their password in chat.

```powershell
. "$HOME\.claude\skills\mms-login\Connect-MMS.ps1"
Set-MMSCredentials -Email anthonym@meyer-msc.com   # prompts securely, run once / when password changes
```

Known working account: `anthonym@meyer-msc.com` (OTP lands in this same
Gmail, already OAuth-connected in Claude Code).

## Login Flow

```powershell
. "$HOME\.claude\skills\mms-login\Connect-MMS.ps1"
$cred  = Get-MMSCredential
$state = Start-MMSLogin -Email $cred.Email -Password $cred.Password
# -> MMS has now emailed a 6-digit OTP. Fetch it (see below), then:
$session = Complete-MMSLogin -LoginState $state -OtpCode $otp
# $session is an authenticated WebSession - reuse it for any further /MMS/... request.
```

`Start-MMSLogin` throws if the password is wrong (detects "Invalid login
Password" instead of reaching the OTP prompt) - don't blindly proceed to the
OTP step without checking for that.

## OTP Retrieval (when driven by Claude Code)

The OTP email arrives within a few seconds, subject `[MMS] Action Required:
Input One-Time Password`, sender `itsupport@meyer-msc.com`, body contains a
bare 6-digit number and expires in **6 minutes**. Fetch it with the connected
Gmail tools:

1. `mcp__claude_ai_Gmail__search_threads` with query
   `from:itsupport@meyer-msc.com newer_than:1h`
2. Take the **newest** message in the result (a stale prior OTP email may
   still be in the thread) and call `mcp__claude_ai_Gmail__get_message` with
   `messageFormat: PLAIN_TEXT`.
3. Extract the 6-digit code (it's the only line matching `^\d{6}$` in
   `plaintextBody`).
4. Call `Complete-MMSLogin` immediately - the code expires in 6 minutes.

For a **fully unattended** (no Claude in the loop) scheduled script, this step
needs its own Gmail API credential with read scope (the existing Weekly
Exchange Rate project's OAuth token is `gmail.compose`-only and can't read
mail) - not yet built, ask the user before setting one up.

**MMS also silently skips the OTP step entirely** once it recognizes the
device/session as already-trusted (seen after several logins in a short
window from the same machine) - `Start-MMSLogin`'s response then lands
straight on `/MMS/Home/Index` instead of the OTP chat widget. Always check
for this (its `HAS_DASHBOARD`/URL check) before assuming a throw means bad
credentials.

## After Login: Pulling Data

Global Design (Product & DEA) → WebSpec exposes clean JSON DataTables APIs
once authenticated (reuse `$session` from above):

| Data | Endpoint | Method | Safe batch size |
|---|---|---|---|
| Product Specification (SKU) | `/MMS/PRS/GetViewSKUSearch` | POST (form-urlencoded, needs `selcol[]` params - see below) | `length=1000` |
| Part Master | `/MMS/PRS/GetPartList` | GET (query string) | `length=500` |
| Product Family (Master Files) | `/MMS/PRS/GetFamiList` | GET (query string), 11 columns incl. a data:null "Actions" placeholder | `length=2315` (all of it in one call - small rows) |

Every Master Files sub-page (Brand, Customer, Factory, Style, Coating, ...)
follows the same `Get<Name>List` naming pattern - view its page source and grep
for `.DataTable(` to find the exact endpoint + column list before hand-building
a request (see Common Mistakes).

Both are standard DataTables server-side endpoints (`draw`, `start`,
`length`, `search[value]`, plus `status=A|I|All`). Going over the safe batch
size throws a server 500 ("...exceeds the value set on the maxJsonLength
property"). For `GetViewSKUSearch`, build the POST body by capturing one real
request from the browser (DevTools/Playwright) and substituting `start`/
`length` - the `selcol[]` column-definition params are required and easy to
get wrong by hand.

Date fields come back as `/Date(1234567890000)/` (or the .NET
`DateTime.MinValue` sentinel `/Date(-62135596800000)/` for "never set") -
convert with `[DateTimeOffset]::FromUnixTimeMilliseconds(...)`.

## Common Mistakes

- Passing the WebSession through `Export-Clixml`/`Import-Clixml` across
  separate PowerShell processes - it deserializes into an incompatible type
  and every subsequent `-WebSession` call fails. Keep the whole login+data-pull
  flow in one PowerShell process/script.
- Re-using an old OTP email instead of the newest one in the thread (MMS
  sends a fresh email per login attempt, all in the same Gmail thread).
- Guessing the `GetViewSKUSearch` POST body by hand - it 500s with a cryptic
  "Index was out of range" error unless every `selcol[]` param from a real
  captured request is present.
- Omitting any column from a hand-built DataTables request (including
  non-data ones like an "Actions" column with `data: null` client-side) -
  these endpoints bind columns positionally server-side and 500 with an
  empty/generic "Internal Server Error" body if the count/order doesn't
  exactly match the page's own `.DataTable({...})` config.
