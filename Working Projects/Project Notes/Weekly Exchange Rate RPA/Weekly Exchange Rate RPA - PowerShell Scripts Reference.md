---
tags: [project, exchange-rate, reference, powershell]
---

# Weekly Exchange Rate RPA — PowerShell Scripts Reference

所有 PowerShell/Node 腳本清單，位於 `C:\Users\User\Desktop\Weekly Exchange Report - CLAUDE\Scripts\`。專案總覽見 [[Weekly Exchange Rate RPA]]；逐步指令見專案內 `Docs\POWERSHELL-COMMANDS.md`（⚠️ 目前只涵蓋到 Phase 3，尚未更新 Phase 4/HTML 報表，此頁以實際腳本行為為準）。
All PowerShell/Node scripts, located in `C:\Users\User\Desktop\Weekly Exchange Report - CLAUDE\Scripts\`. Project overview: [[Weekly Exchange Rate RPA]]; step-by-step commands: `Docs\POWERSHELL-COMMANDS.md` inside the project folder (⚠️ currently only covers through Phase 3, not yet updated for Phase 4/the HTML report — this page reflects actual current script behavior).

> 下面每個指令都假設已經先切到 Scripts 資料夾，且 `FIN_Ex Rate_PSBUILD_TEMP.xlsx` 未在 Excel 中開啟：
> Every command below assumes you've `cd`'d into the Scripts folder, and `FIN_Ex Rate_PSBUILD_TEMP.xlsx` is closed in Excel:
> ```powershell
> cd "C:\Users\User\Desktop\Weekly Exchange Report - CLAUDE\Scripts"
> ```

## 每週核心流程 / Weekly core pipeline

實際執行順序是 1→2→**4→3**（Phase 4 在 Phase 3 之前）——原因見下方 `Run-WeeklyPipeline.ps1` 的說明。
Actual run order is 1→2→**4→3** (Phase 4 before Phase 3) — see the `Run-WeeklyPipeline.ps1` note below for why.

| 順序 Order | 腳本 Script                                                                                                          | 用途 Purpose                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | 指令 Command                                                                                                                                                                                                                                                                 |
| -------- | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1        | `Get-WeeklyExchangeRates.ps1`<br>（腳本自稱 Phase 1）                                                                    | 從三個公開資料源（Pacific Exchange Rate Service、ChinaMoney CFETS、HSBC Currency Zone）抓本週匯率，寫入新的 `NEW DATA_PSBUILD_<date>.xlsx`；只讀不寫正式檔案 Fetches this week's rates from three public sources (Pacific Exchange Rate Service, ChinaMoney CFETS, HSBC Currency Zone), writes a new `NEW DATA_PSBUILD_<date>.xlsx`; read-only against production files                                                                                                                                                                                                                     | `.\Get-WeeklyExchangeRates.ps1`                                                                                                                                                                                                                                            |
| 2        | `Update-FinExRateReport.ps1`<br>（腳本自稱 Phase 2）                                                                     | 把新資料併入常駐工作檔 `FIN_Ex Rate_PSBUILD_TEMP.xlsx`（就地更新，不再靠比較多個候選檔時間戳記猜測基準檔——見 [[Skill - Incremental Report File Chaining]]），並自動執行重複日期稽核 Merges the new data into the persistent working file `FIN_Ex Rate_PSBUILD_TEMP.xlsx` (updated in place — no more guessing the base file via timestamp comparison, see [[Skill - Incremental Report File Chaining]]), runs an automatic duplicate-date audit                                                                                                                                                                | `.\Update-FinExRateReport.ps1`                                                                                                                                                                                                                                             |
| 3        | `Update-HtmlReport.ps1`<br>（腳本自稱 Phase 4，但實際上先於 Phase 3 執行 / self-labels Phase 4 but actually runs before Phase 3） | 直接針對 TEMP 工作檔重建17分頁互動式HTML報表（含CSV下載按鈕、日期篩選、行動裝置修正——見 [[Skill - Excel to Interactive HTML Report]]）；日期戳直接從 Data 分頁資料算出（Sunday-completing規則），不再依賴已命名快照，移除了原本「Phase 3必須先跑」的順序相依性 Rebuilds the 17-tab interactive HTML report directly against the TEMP working file (CSV download buttons, date filters, mobile fixes — see [[Skill - Excel to Interactive HTML Report]]); computes its own date stamp from the Data sheet (Sunday-completing rule) instead of parsing an already-dated filename, removing the old "Phase 3 must run first" ordering dependency | `.\Update-HtmlReport.ps1`（省略 `-XlsxPath` 會自動抓最新已命名快照；正式流程改為明確指向 TEMP 檔 / omitting `-XlsxPath` auto-picks the newest dated snapshot; production now points it explicitly at the TEMP file）<br>`.\Update-HtmlReport.ps1 -XlsxPath "..\Output\FIN_Ex Rate_PSBUILD_TEMP.xlsx"` |
| 4        | `New-WeeklyEmailDraft.ps1`<br>（腳本自稱 Phase 3）                                                                       | 建立本週正式命名快照（`FIN_Ex Rate_PSBUILD_<週日日期>.xlsx`）+ Gmail 草稿：附加該快照，並附加上一步剛產出的HTML報表（若缺少則優雅降級只附xlsx，不中斷）；~45人收件人清單，只建草稿絕不自動寄出 Creates this week's dated snapshot (`FIN_Ex Rate_PSBUILD_<Sunday date>.xlsx`) + the Gmail draft: attaches that snapshot, plus the HTML report the previous step just built (gracefully degrades to xlsx-only if missing, never throws); ~45-recipient list, only ever creates a draft, never auto-sends                                                                                                                              | `.\New-WeeklyEmailDraft.ps1`                                                                                                                                                                                                                                               |

## 整合排程 / Orchestration

| 腳本 Script | 用途 Purpose | 指令 Command |
|---|---|---|
| `Run-WeeklyPipeline.ps1` | 排程進入點：依序執行 Phase 1→2→**4→3**。原因：Phase 3的Email草稿需要附加Phase 4剛產出的HTML，若照腳本自身編號順序（1→2→3→4）執行，草稿建立時HTML還不存在（2026-08-24發現的真實bug，已修復）。Phase 1/2 共用一個try/catch快速失敗；Phase 4、Phase 3 各自獨立try/catch，互不阻擋——Phase 4壞掉不會讓Phase 3的草稿也失敗。由每週一 09:00 Windows排程任務 `WeeklyExchangeRateReport` 觸發 Scheduled entry point: runs Phase 1→2→**4→3** in that order. Why: Phase 3's email draft needs to attach the HTML Phase 4 just built — running in the scripts' own self-labeled order (1→2→3→4) meant the draft was created before the HTML existed (a real bug found 2026-08-24, now fixed). Phase 1/2 share one fail-fast try/catch; Phase 4 and Phase 3 are each independently try/catch'd so neither blocks the other — a Phase 4 failure never breaks Phase 3's draft. Triggered by the Monday 09:00 Windows Scheduled Task `WeeklyExchangeRateReport` | `.\Run-WeeklyPipeline.ps1` |

## 一次性設定 / One-time setup

| 腳本 Script | 用途 Purpose | 指令 Command |
|---|---|---|
| `Connect-GmailOAuth.ps1` | 一次性 Gmail OAuth 授權：本機迴路監聽接收授權碼，換取 refresh token，以 Windows DPAPI 加密保存（綁定本機本帳號）。僅需執行一次，除非權限被撤銷，或OAuth同意畫面仍是"Testing"模式（約7天過期一次）One-time Gmail OAuth authorization: runs a local loopback listener to catch the redirect, exchanges for a refresh token, stores it encrypted via Windows DPAPI (tied to this machine/user). Only needed once, unless access is revoked or the OAuth consent screen is still in "Testing" mode (expires roughly every 7 days) | `.\Connect-GmailOAuth.ps1`（互動輸入 Client ID/Secret / prompts for Client ID/Secret，設定步驟見 `Docs\PHASE3_GMAIL_OAUTH_SETUP.md`） |
| `GmailOAuth.Common.ps1` | 共用函式庫（被 `Connect-GmailOAuth.ps1` 與 `New-WeeklyEmailDraft.ps1` dot-source 引用，不會單獨執行）Shared helper library (dot-sourced by both `Connect-GmailOAuth.ps1` and `New-WeeklyEmailDraft.ps1`, never run directly) | （不要直接執行，會被自動引用 / never run directly, auto-referenced） |

## 輔助工具（自動呼叫，不單獨執行）/ Helper tool (auto-invoked, never run directly)

| 腳本 Script | 用途 Purpose | 指令 Command |
|---|---|---|
| `Build-CombinedHtmlReport.js` | 被 `Update-HtmlReport.ps1` 自動呼叫的 Node.js 腳本，把17個分頁合併成單一自包含HTML檔（email單一附件用，用 `iframe.srcdoc` 而非 `src` 載入，不需要額外資料夾）。用 Node 而非 PowerShell here-string，是因為要安全處理內嵌內容裡的 `$`/反引號跳脫，以及中和內嵌JSON字串中的 `</script` 序列——詳見 [[Skill - Excel to Interactive HTML Report]] Node.js script auto-invoked by `Update-HtmlReport.ps1`, combines all 17 tabs into one self-contained HTML file (for single-attachment email use, loads each sheet via `iframe.srcdoc` not `src`, no separate folder needed). Done in Node rather than a PowerShell here-string to safely handle `$`/backtick escaping in the embedded content and neutralize `</script` sequences inside the embedded JSON — see [[Skill - Excel to Interactive HTML Report]] | （不要直接執行，Update-HtmlReport.ps1 需要Node.js在PATH上時會自動呼叫；找不到Node時會跳過此步驟並產出警告，多檔版報表仍會正常產出 / never run directly — auto-invoked by Update-HtmlReport.ps1 when Node.js is on PATH; if Node isn't found this step is skipped with a warning, the multi-file version is still produced） |

## 不適用/歷史一次性檔案 / Not applicable — historical

| 腳本 Script | 用途 Purpose | 為何不適用 Why not applicable | 指令 Command |
|---|---|---|---|
| `New-WeeklyEmailDraft - 複製.ps1` | 舊版備份副本（2026-07-31）Old backup copy (2026-07-31) | 已被目前的 `New-WeeklyEmailDraft.ps1`（2026-08-24更新，含HTML附件邏輯）取代 Superseded by the current `New-WeeklyEmailDraft.ps1` (updated 2026-08-24, includes the HTML-attachment logic) | （不建議執行 / not recommended to run） |

## 相關 / Related

- 專案總覽：[[Weekly Exchange Rate RPA]]
  Project overview: [[Weekly Exchange Rate RPA]]
- HTML報表互動層的完整技術寫法/坑（flatpickr行動版切換、WebKit `new Date()` 解析陷阱、CSV下載按鈕實作等）：[[Skill - Excel to Interactive HTML Report]]
  Full technical pattern/gotchas for the HTML report's interactivity layer (flatpickr mobile-swap, WebKit `new Date()` parsing trap, CSV download button implementation, etc.): [[Skill - Excel to Interactive HTML Report]]
- 增量報表檔案串接的架構原則（TEMP工作檔 vs. 猜測基準檔）：[[Skill - Incremental Report File Chaining]]
  Architecture principle behind the TEMP working-file pattern (vs. guessing a base file): [[Skill - Incremental Report File Chaining]]
- Gmail OAuth 設定被 [[Global Purchase Report RPA]] 和 [[RMB CNH Exchange Rate (May Lau)]] 兩個專案重複使用（複製加密token，同帳號同權限範圍，不用重新授權）
  This project's Gmail OAuth setup is reused by both [[Global Purchase Report RPA]] and [[RMB CNH Exchange Rate (May Lau)]] (copied encrypted token, same account/scope, no re-authorization needed)

## Full detail / 完整細節

`C:\Users\User\.claude\projects\c--Users-User-Desktop\memory\project_weekly_exchange_rate_rpa.md`
專案資料夾 Project folder: `C:\Users\User\Desktop\Weekly Exchange Report - CLAUDE\`
