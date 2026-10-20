---
tags: [moc, working-projects]
---

# Working Projects

This section maps the working-project repositories, with an emphasis on recurring finance operations, reporting, and PowerShell processing. Each repository page records its purpose, checkout path, GitHub source, entry points, and handling notes.

## Repository map

| Repository page | Work area | What it does | GitHub repository |
|---|---|---|---|
| [[ALUM Purchase Report]] | Monthly reporting automation | PowerShell and Excel COM workflow for the MIL, MZQ and STC aluminum purchase report. Combines exports and exchange rates, updates the dated workbook, and can produce a self-contained interactive HTML report. | alum-report-claude |
| [[MPL]] | Financial close and property system | Meyer Properties monthly close tools and browser-based property management system, including accounting, journal generation, property register, debit/credit notes and receipt workflows. The repository also carries the HK finance skills source folder. | MPL |
| [[MPL System Portal]] | Finance system portal | MPL system portal repository and standalone portal/deployment source associated with the MPL workflow. | MPL-System |
| [[System Module]] | Reusable finance system template | Company-agnostic browser system template with a login-gated launcher and standalone accounting, inventory, investment, and debit/credit note and receipt modules. | System-Module |
| [[EIC Goldman Sachs Processing]] | Monthly close processing | Tools and working files for EIC monthly Goldman Sachs portfolio processing and close, including statement ingestion, journal, ledger and reporting workflows. | EIC |
| [[GPL Gold Plume]] | Monthly close processing | Gold Plume close automation with UBS and JPM bank statement or notice processors, financial statement workbook support, and management update drafting. | GPL |
| [[Global Purchase Report]] | Monthly reporting automation | PowerShell rebuild of the multi-entity Global Purchase Report process. Manual data exports feed automated merging, Excel report production and related HTML and notification steps. | global-purchase-report-claude |
| [[MTC Purchase Report]] | Monthly reporting automation | MTC purchase report and commission processing repository. Review the current SOP and dated monthly folders before running the process. | MTC_Purchase_Report |
| [[MTC Sales Report]] | Monthly reporting automation | Monthly MTC sales and commission processing. Manual MMS/EPICOR downloads feed scripts that prepare rows and values and merge them into the master report. | MTC_Sales_Report |
| [[Weekly Exchange Rate Report]] | Exchange rate automation | PowerShell rebuild of the weekly exchange-rate report, including data fetch, Excel dashboard and interactive HTML output. Documentation also covers Slack posting and an exchange-rate Q&A bot. | weekly-exchange-rate-report-powershell |
| [[RMB CNH Exchange Report]] | Exchange rate automation | Monthly HKD/RMB or CNH exchange-rate reporting automation using BOC data and a Claude Code skill workflow. | rmb-cnh-exchange-rate-report |
| [[FBW Royalty Report]] | Quarterly reporting automation | Quarterly Farberware Percolator royalty processing. Uses the signed royalty statement PDF and MTC shipment master to prepare the next-quarter FIN_MIP workbook. | FBW_Royalty |
| [[Hong Kong Tax Study Hub]] | Reference and study tools | Hong Kong tax study aid covering profits, property and salaries tax, stamp duty, depreciation allowances, IRD guidance and worked examples. | hktax-studyhub |
| [[HKICPA Standards and Study Library]] | Reference library | Reference collection of HKFRS and HKAS material and accounting study documents. | HKICPA |
| [[HKFRS AS Study Platform]] | Reference and study tools | Browser-based HKFRS and accounting standards study platform. | hkfrs-as-study-platform |
| [[Desktop OneDrive Sync]] | Windows automation | PowerShell and Robocopy automation that mirrors Desktop content into the Desktop OneDrive folder, with logging and exit-code handling. | desktop-onedrive-sync |
| [[IELTS Prep Desk]] | Personal learning tools | Single-file browser app for vocabulary, reading, listening, writing, speaking, grammar and dictionary practice. | ielts-prep |
| [[GitHub Desktop Tutorial]] | Developer learning and process | GitHub Desktop tutorial repository for learning or documenting the GitHub Desktop workflow. | Github |
| [[SageMaker MovieLens]] | Developer learning and process | Amazon SageMaker Factorization Machines MovieLens example for recommendation-model learning. | sagemaker-fm-movielens |
## Operating model

- Use the repository README and current SOP as the working instructions; this index is a navigation layer.
- Treat the GitHub repository as the source for versioned code and shared documentation. Local source data, workbooks and outputs may intentionally stay outside Git.
- Before running PowerShell or Excel automation, confirm the reporting period, input files, output destination, external notifications, and whether the operation changes business records.
- Validate completed reports against their source files and accounting evidence before release.
- Keep project-specific operating notes in [[Project Notes]]. The repository pages are the current overview; older notes remain available as supporting history.

## Related

- [[README|Second Brain Home]]
- [[Skills/Skills Overview|Skills Index]]