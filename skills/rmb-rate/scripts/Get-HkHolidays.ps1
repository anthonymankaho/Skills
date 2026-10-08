<#
Fetches the official Hong Kong government public holiday calendar and returns the
set of holiday dates as [datetime] objects. Source: 1823.gov.hk's published ICS
feed (the same one HKSARG uses for "Hong Kong Public Holidays"), fetched live each
run rather than hardcoded, so it needs no annual maintenance.
#>
$ErrorActionPreference = 'Stop'

$url = 'https://www.1823.gov.hk/common/ical/en.ics'
$response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 20
$matches = [regex]::Matches($response.Content, 'DTSTART;VALUE=DATE:(\d{8})')

$holidays = foreach ($m in $matches) {
    [datetime]::ParseExact($m.Groups[1].Value, 'yyyyMMdd', $null)
}
if (-not $holidays) { throw "No holiday dates parsed from $url - the feed format may have changed." }

$holidays
