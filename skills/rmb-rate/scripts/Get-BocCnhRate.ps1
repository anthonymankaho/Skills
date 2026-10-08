<#
Fetches the BOC HK offshore RMB (CNH) rate and computes the workbook's rate
convention (HKD1 = X CNH, sell, offshore) - pure PowerShell/regex, no AI-assisted
parsing needed, since this iframe URL returns plain static HTML (unlike the outer
hkdrates.html wrapper page, which is a JS shell).

Returns a PSCustomObject: SellRate (BOC 客戶賣出), BuyRate (BOC 客戶買入), WorkbookRate.
#>
$ErrorActionPreference = 'Stop'

$url = 'https://www.bochk.com/whk/rates/exchangeRatesHKD/exchangeRatesHKD-input.action?lang=hk'
$response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 20
$content = $response.Content

$pattern = '人民幣\(離岸\)[\s\S]*?<td>[\s\S]*?([\d\.]+)[\s\S]*?</td>[\s\S]*?<td>[\s\S]*?([\d\.]+)[\s\S]*?</td>'
if ($content -notmatch $pattern) {
    throw "Could not find the 人民幣(離岸) row on $url - the page structure may have changed."
}

$sellRate = [double]$Matches[1]
$buyRate = [double]$Matches[2]
$workbookRate = [Math]::Round(1 / $sellRate, 4)

[PSCustomObject]@{
    SellRate     = $sellRate
    BuyRate      = $buyRate
    WorkbookRate = $workbookRate
}
