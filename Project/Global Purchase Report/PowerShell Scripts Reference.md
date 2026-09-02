---
tags: [project, purchase-report, reference, powershell]
---

# Global Purchase Report — PowerShell Scripts Reference

所有 PowerShell 腳本清單，位於 `C:\Users\User\Desktop\Global Purchase Report Claude\`。完整流程圖見 [[Global Purchase Report RPA - Monthly Pipeline]]，逐步指令見專案內 `PowerShell-Commands.md`/`SOP-Quick-Guide.md`。
All PowerShell scripts, located in `C:\Users\User\Desktop\Global Purchase Report Claude\`. Full pipeline diagram: [[Global Purchase Report RPA - Monthly Pipeline]]; step-by-step commands: `PowerShell-Commands.md`/`SOP-Quick-Guide.md` inside the project folder.

> 下面每個指令都假設已經先切到專案資料夾、設定好 `$ReportMonth`（每月只改這一行）：
> Every command below assumes you've already `cd`'d into the project folder and set `$ReportMonth` (only line to change each month):
> ```powershell
> cd "C:\Users\User\Desktop\Global Purchase Report Claude"
> $ReportMonth = "2026-07"
> ```

## 資料索取 / Data collection (runs first, before the core pipeline)

| 腳本 Script | 用途 Purpose | 指令 Command |
|---|---|---|
| `New-InterGroupPurchaseDataRequestDrafts.ps1` | 月初向 MZQ/MIL/RACO/TVS/MAZ 索取當月採購資料，建立 5 封各自語言的 Gmail 草稿（`-ReportMonth` 為執行當月，自動往前推一個月當索取期間）Requests that month's purchase data from MZQ/MIL/RACO/TVS/MAZ, creating 5 Gmail drafts each in that contact's language (`-ReportMonth` is the run month, auto-offset -1 month for the requested period) | `.\New-InterGroupPurchaseDataRequestDrafts.ps1 -ReportMonth $ReportMonth`（`-Only MZQ` 可只建單一草稿測試 / `-Only MZQ` for a single test draft） |

## 每月核心流程 / Monthly core pipeline

| # | 腳本 Script | 用途 Purpose | 指令 Command |
|---|---|---|---|
| 1 | `Build-GlobalPurchaseReport.ps1` | 合併7個實體（MHK/STC/MZQ/MIL/RACO/TVS/MAZ）資料＋更新匯率表，產出當月新報表 Merges all 7 entities' data + updates the exchange rate block, produces this month's new Report file | `.\Build-GlobalPurchaseReport.ps1 -ReportMonth $ReportMonth` |
| 1.5 | `Get-PenExchangeRate.ps1` | 補 `STANDARD EXCHANGE RATE.xls` 缺少的 PEN 匯率（MAZ 用），從 Pacific Exchange Rate Service 抓 USD/PEN 換算寫入 Exchange Rate 分頁 M欄 Fills the PEN rate gap needed for MAZ, fetches USD/PEN and writes it into the Exchange Rate tab column M | `.\Get-PenExchangeRate.ps1 -ReportMonth $ReportMonth` |
| — | 👤 手動複製 `AA2:AB2` 到新增列並計算 Manually copy `AA2:AB2` down + calculate | Max/Min PO Price，下一步的前提 Precondition for next step | （在 Excel 裡手動操作，非 PowerShell / manual in Excel, not PowerShell） |
| 3 | `Complete-FormulaColumns.ps1` | 手動填好 AA/AB 之後執行：依相依順序填/凍結 AC~AI 公式，並建立「New Vendors」複核分頁 Run after manually filling AA/AB: fills/freezes AC–AI in dependency order, builds the New Vendors review sheet | `.\Complete-FormulaColumns.ps1 -ReportMonth $ReportMonth` |
| — | `Update-TVSTranslations.ps1` | 修正 TVS 翻譯欄與 Commodity Code（若當月已用 Excel Copilot 手動處理過可略過）Fixes TVS's translation column and Commodity Code (skip if already handled manually via Excel Copilot this month) | `.\Update-TVSTranslations.ps1` |
| 4 | `New-ReportAuditSummary.ps1` | （建議）唯讀稽核摘要：報表最後列號、七實體當月列數、當月總列數 (Recommended) read-only audit summary: last row, each entity's row count, total rows this month | `.\New-ReportAuditSummary.ps1 -ReportMonth $ReportMonth` |
| 5 | `Publish-OutsideReport.ps1` | 產出外部交付檔：複製數值進 `OUTSIDETEMP.xlsx` + `OUTSIDETEMP_VBA_PRACTICE.xlsm`、延伸表格、重新整理樞紐分析表、另存當月交付檔（含自動遞增RV編號）Produces the outside-delivery deliverable: value-copies into both files, extends the tables, refreshes all PivotTables, Save-As's the dated deliverable | `.\Publish-OutsideReport.ps1 -ReportMonth $ReportMonth` |

## 通知/發布自動化 / Notification & distribution automation

| #   | 腳本 Script                   | 用途 Purpose                                                                                                                                                                                                                                                                              | 指令 Command                                                                    |
| --- | --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| 8   | `New-MonthlyEmailDraft.ps1` | 建立 Gmail 草稿通知（比照舊UiPath RPA的收件人清單/主旨/內文格式，目前15人=3位To+12位Cc，只建草稿絕不自動寄出）Creates a Gmail draft (matches the old UiPath RPA's recipient list/subject/body format, currently 15 people = 3 To + 12 Cc, only ever creates a draft, never auto-sends)                                                                                  | `.\New-MonthlyEmailDraft.ps1 -ReportMonth $ReportMonth`                       |
| 9   | `New-MonthlySlackPost.ps1`  | 發到 Slack `global_purchase_report` 私人頻道，附加互動式HTML報表——**沒有草稿機制，執行後立刻真實發布** Posts to the Slack `global_purchase_report` private channel with the interactive HTML report attached — **no draft concept, posts live immediately**                                                           | `.\New-MonthlySlackPost.ps1 -ReportMonth $ReportMonth -Channel "C0BSWRJU85T"` |
| —   | `Save-SlackToken.ps1`       | 一次性設定：把 Slack Bot Token 加密儲存 One-time setup: encrypts and stores the Slack Bot Token                                                                                                                                                                                                    | `.\Save-SlackToken.ps1`（會提示貼上 token / prompts you to paste the token）         |
| —   | `GmailOAuth.Common.ps1`     | 共用函式庫（被 `New-MonthlyEmailDraft.ps1` dot-source 引用，不會單獨執行）；沿用 [[Weekly Exchange Rate RPA]] 專案已授權的 Gmail OAuth Shared helper library (dot-sourced by `New-MonthlyEmailDraft.ps1`, never run directly); reuses the Gmail OAuth already authorized for the Weekly Exchange Rate RPA project | （不要直接執行，會被自動引用 / never run directly, auto-referenced）                         |

## 獨立工具 / Standalone tool

| 腳本 Script | 用途 Purpose | 指令 Command |
|---|---|---|
| `Global Purchase Report RPA\HTML_Report_Generator\Generate-PurchaseReportHtml.ps1` | 把當月最終報表轉成單一自包含互動式HTML檔案（Dashboard圖表、GLID/Fittings/Packaging/Coating篩選、Exchange Rate互動表格）。刻意不接自動化流程，需等 AA/AB 定稿後手動執行；`-Publish` 才產出正式命名快照，平常只更新 TEMP 預覽檔 Converts the finalized monthly report into a single self-contained interactive HTML file. Deliberately manual, run only after AA/AB are finalized; `-Publish` produces the dated snapshot, otherwise only updates the TEMP preview file | `cd "Global Purchase Report RPA\HTML_Report_Generator"`<br>`.\Generate-PurchaseReportHtml.ps1 -Publish`（測試不加 `-Publish` / omit `-Publish` for a test run） |
| `Global Purchase Report RPA\HTML_Report_Generator\Copy-ProdFamiDescToSource.ps1` | 一次性/視需要：把 `OUTSIDETEMP.xlsx` 已算好的 ProdFamiDesc（產品家族）值，逐列核對對齊後複製進正式月報來源檔的新增第37欄；核對不過直接中止不寫入 One-off/as-needed: copies OUTSIDETEMP.xlsx's computed ProdFamiDesc (Product Family) values into a new 37th column on the official source file, only after verifying every row aligns; aborts without writing if any row doesn't match | `cd "Global Purchase Report RPA\HTML_Report_Generator"`<br>`.\Copy-ProdFamiDescToSource.ps1` |

## 不適用/歷史一次性腳本 / Not applicable — historical one-offs

| 腳本 Script | 用途 Purpose | 為何不適用 Why not applicable | 指令 Command |
|---|---|---|---|
| `Fix-JuneReportFormulaErrors.ps1` | 修補6月報表既有的公式錯誤 Patches pre-existing formula errors in the June report | 寫死指向 `..._2026-06.xlsx`，6月專用一次性腳本 Hardcoded to `..._2026-06.xlsx`, a June-only one-off | （不建議執行 / not recommended to run） |
| `_patch_exchange_rate.ps1` | 補寫6月報表 Exchange Rate 分頁遺漏的匯率值 Backfills missing exchange rate values into the June report | 同上，寫死 `-Month "2026-06"` Same, hardcoded to `-Month "2026-06"` | （不建議執行 / not recommended to run） |

## 相關 / Related

- 完整月度流程圖（含每支腳本當月執行狀態）：[[Global Purchase Report RPA - Monthly Pipeline]]
  Full monthly pipeline diagram (with each script's current-month run status): [[Global Purchase Report RPA - Monthly Pipeline]]
- 專案總覽：[[Global Purchase Report RPA]]
  Project overview: [[Global Purchase Report RPA]]
