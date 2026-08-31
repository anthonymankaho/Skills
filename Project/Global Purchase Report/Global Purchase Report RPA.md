---
tags: [project, purchase-report, rpa]
---

# Global Purchase Report RPA

每月把7個實體（MHK、STC、MZQ、MIL、RACO、TVS、MAZAL）的採購資料合併成一份報表——原本是 UiPath RPA 流程，現在改用 PowerShell 重建（合併/產出報表＋通知/發布皆已自動化；EPICOR 匯出、MMS 上傳、Gmail 草稿的最終寄出仍為人工）。
Monthly report merging purchase data from 7 entities (MHK, STC, MZQ, MIL, RACO, TVS, MAZAL) — historically a UiPath RPA process, now rebuilt in PowerShell (merge/report-generation AND notify/distribute are both automated; EPICOR export, MMS upload, and actually sending the Gmail draft stay manual).

## Current state / 目前狀態

- **2026-07 月結已完成**（2026-08-26）：7個實體皆已用實際日期欄位驗證資料就緒（不只看檔案時間戳記）；Build → Get-PenExchangeRate → 手動AA/AB → Complete-FormulaColumns → Publish-OutsideReport 全部成功執行。SOP 升級到 v1.13。
  **2026-07 monthly close completed** (2026-08-26): all 7 entities confirmed data-ready via actual date-column checks (not just file timestamps); Build → Get-PenExchangeRate → manual AA/AB → Complete-FormulaColumns → Publish-OutsideReport all run successfully. SOP bumped to v1.13.
- `Get-PenExchangeRate.ps1` 現已正式串接並於本月成功使用：從 Pacific Exchange Rate Service 抓 USD/PEN，換算成 HKD 基準，寫入 Exchange Rate 分頁（M欄）；PEN→USD 公式維持活公式，不寫死數字。
  `Get-PenExchangeRate.ps1` is now fully wired in and used successfully this month: fetches USD/PEN from the Pacific Exchange Rate Service, converts to HKD basis, writes into the Exchange Rate tab (column M); the PEN→USD formula stays live, never hardcoded.
- `Publish-OutsideReport.ps1` 擴充為同步數值複製進**兩個**目的檔案：`OUTSIDETEMP.xlsx` 和 `OUTSIDETEMP_VBA_PRACTICE.xlsm`。新增啟動前 EXCEL.EXE 偵測（報錯中止而非強制關閉）與手動計算模式（`xlCalculationManual`）——修正了實測曾耗時46分鐘以上、因自動計算模式在每個中間步驟都觸發整個活頁簿重算所造成的效能問題。
  `Publish-OutsideReport.ps1` extended to sync value-copies into **two** destination files: `OUTSIDETEMP.xlsx` and `OUTSIDETEMP_VBA_PRACTICE.xlsm`. Added a pre-run EXCEL.EXE check (aborts rather than force-closing) and manual calculation mode (`xlCalculationManual`) — fixed a real 46+ minute runtime caused by full-workbook auto-recalc firing on every intermediate step.
- ✅ **已解決**（2026-08-27）：`OUTSIDETEMP_VBA_PRACTICE.xlsm` 有跟 `OUTSIDETEMP.xlsx` 之前一樣的已損壞/缺失 `data` 命名範圍問題——人工在名稱管理員**新增**（非編輯，因為完全缺失）工作表層級名稱 `data` 指向 `=Table1[#All]`，用三種方式交叉驗證（25個樞紐分析表全部重新整理成功、`COUNTA(data)`回傳合理列數、欄位名稱正確）。
  ✅ **Resolved** (2026-08-27): `OUTSIDETEMP_VBA_PRACTICE.xlsm` had the same broken/missing `data` named range `OUTSIDETEMP.xlsx` had — fixed by manually **creating** (not editing, since it was fully missing) a workbook-scoped `data` name pointing at `=Table1[#All]`, cross-verified three ways (all 25 PivotTables refresh successfully, `COUNTA(data)` returns a sensible row count, field names are correct).
- 已修復 `OUTSIDETEMP.xlsx` 一個真實存在的命名範圍損壞 bug（原本導致18個樞紐分析表無法重新整理）。
  Fixed a real corrupted-named-range bug in `OUTSIDETEMP.xlsx` (18 PivotTables were failing to refresh).
- 互動式 HTML 報表產生器（`build_report.js` + `Generate-PurchaseReportHtml.ps1`）大幅重寫：項目收合按鈕、DB 圖表顏色一致性、欄寬自動調整、白話版 Ignore/Consider 篩選器、Exchange Rate 頁重建為 DataTables 互動表格、修正來源檔案自動偵測改依報表期間排序（不再依檔案異動時間）。
  Interactive HTML report generator (`build_report.js` + `Generate-PurchaseReportHtml.ps1`) heavily reworked: item-level collapse toggle, DB chart color consistency, column autofit, Ignore/Consider filter with plain-language labels, Exchange Rate page rebuilt as a DataTables page, source-file auto-detection fixed to sort by reporting period (not file-touch time).
- VBA 按鈕原型（`HtmlUpdateModule.bas`）已完成沙盒測試，可從 Excel 觸發 HTML 產出——尚未正式部署（巨集安全性政策未確認）。
  VBA button prototype (`HtmlUpdateModule.bas`) sandbox-tested for triggering the HTML build from Excel — not yet deployed (macro-security policy unconfirmed).
- 專案資料夾新增快速參考文件：`PowerShell-Commands.md`（改用單一 `$ReportMonth` 變數，每月僅需改一行）、`PowerShell-Runtime-Report.md`、`SOP-Quick-Guide.md`。
  New quick-reference docs added to the project folder: `PowerShell-Commands.md` (now uses a single `$ReportMonth` variable — one line to change each month), `PowerShell-Runtime-Report.md`, `SOP-Quick-Guide.md`.
- **每月通知/發布自動化，已完整實跑成功**（2026-08-27）：`New-MonthlyEmailDraft.ps1`（Gmail草稿，比照舊RPA的16人收件人清單/格式——3位To+13位Cc，此前一直誤記為13人已更正，只建草稿絕不自動寄出，沿用 [[Weekly Exchange Rate RPA]] 專案已授權的 Gmail OAuth）+ `New-MonthlySlackPost.ps1`（Slack `global_purchase_report` 私人頻道貼文，**即時發布無草稿機制**，會真的附加互動式HTML報表，用 Slack 新版三步驟上傳流程）。2026-07月份：Gmail草稿已由使用者親自檢查並**真的寄出**給16位真實收件人；Slack貼文也已真的發布到頻道。兩支腳本都加了 `-IncludeHtmlIntro` 開關（預設開啟），第一次介紹網頁版報表用的一次性文案，之後月份可關閉。實測發現兩個真實bug：(1) 私人頻道的檔案上傳API必須用頻道ID，不能像發訊息一樣用頻道名稱；(2) Slack附件路徑原本寫死抓無日期後綴檔名，但該檔案在 `-Publish` 後會被改名成有日期後綴，已修正為依 `-ReportMonth` 自動算出正確檔名。
  **Monthly notification automation, fully run for real** (2026-08-27): `New-MonthlyEmailDraft.ps1` (Gmail draft, matches the old RPA's 16-person recipient list/format — 3 To + 13 Cc, corrected from an earlier mistaken "13-person" count — only ever creates a draft, reuses the Gmail OAuth already authorized for [[Weekly Exchange Rate RPA]]) + `New-MonthlySlackPost.ps1` (Slack `global_purchase_report` private-channel post, **posts live with no draft concept**, actually attaches the interactive HTML report via Slack's newer 3-step upload flow). For 2026-07: the Gmail draft was reviewed by the user and **actually sent** to all 16 real recipients; the Slack post also actually went live in the channel. Both scripts gained an `-IncludeHtmlIntro` switch (default on) for the one-time "here's the new web version" callout, toggle-off-able in later months. Two real bugs found: (1) private-channel file uploads need a channel ID, not a channel name like message posting; (2) the Slack attachment path was hardcoded to an undated filename that got renamed to a dated one after `-Publish` - fixed to compute the correct dated filename from `-ReportMonth`.

## Monthly Pipeline / 每月流程

見 [[Global Purchase Report RPA - Monthly Pipeline]]——每月重複執行的 PowerShell 步驟子心智圖（Build → PEN匯率 → 手動AA/AB → Complete-FormulaColumns → 稽核摘要 → Publish → 選用HTML → Gmail草稿 → Slack發布），含每支腳本的用途與2026-07目前執行狀態。純文字版清單見 [[PowerShell Scripts Reference]]。
See [[Global Purchase Report RPA - Monthly Pipeline]] — sub-mind-map of the recurring PowerShell steps (Build → PEN rate → manual AA/AB → Complete-FormulaColumns → Audit Summary → Publish → optional HTML → Gmail draft → Slack post), with each script's purpose and current 2026-07 run status. Plain-text list version: [[PowerShell Scripts Reference]].

## Related / 相關

- 大量使用 [[Skill - Excel to Interactive HTML Report]] 和 [[Skill - Incremental Report File Chaining]]。
  Uses [[Skill - Excel to Interactive HTML Report]] and [[Skill - Incremental Report File Chaining]] extensively.
- 與 [[RMB CNH Exchange Rate (May Lau)]] 及下方的匯率專案不同（不同報表、不同實體範圍）。
  Distinct from [[RMB CNH Exchange Rate (May Lau)]] and the exchange rate projects below (different report, different entity scope).
- Gmail 草稿自動化沿用 [[Weekly Exchange Rate RPA]] 專案的 OAuth 設定（複製加密 token，同帳號同權限範圍，不用重新授權）。
  Gmail draft automation reuses [[Weekly Exchange Rate RPA]]'s OAuth setup (copied encrypted token, same account/scope, no re-authorization needed).

## Full detail / 完整細節

`C:\Users\User\.claude\projects\c--Users-User-Desktop\memory\project_global_purchase_report_rpa.md`
專案資料夾 Project folder: `C:\Users\User\Desktop\Global Purchase Report Claude\`
