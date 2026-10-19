# Windows Dev Scratchpad

**Small PowerShell tools for Windows, written to do the job without turning a five-minute task into a software project.**

I've accumulated enough one-off scripts to know how it goes: you fix something on one machine, forget where you put the fix, then write it again six months later. This repository is where those useful little jobs now live.

Most of the scripts are independent. Run one, get the answer, leave. There's also a lightweight launcher for related TABARC-Code utilities, a PC rebuild inventory and a weekly privacy-maintenance script. I haven't tried to turn every command into a service. Not everything needs a dashboard.

## What is in the repository?

| Script | What it actually does |
| --- | --- |
| `01-Serve-Here.ps1` | Serves the current folder over HTTP using Python, with optional automatic port selection. |
| `02-Watch-File.ps1` | Watches one file for changes to its modification time and size. |
| `03-Watch-Folder.ps1` | Watches the number of files in a folder; non-recursive. |
| `04-Diff-Folders.ps1` | Uses Robocopy's dry-run mode to show differences between two folders. |
| `05-Snapshot-Folder.ps1` | Writes a recursive file inventory to JSON. |
| `06-What-Changed.ps1` | Compares two of those snapshots for added, missing or altered entries. |
| `07-Tail-Log.ps1` | Follows a log file, displaying new lines as they arrive. |
| `08-Quick-Hash.ps1` | Calculates the SHA-256 hash of a file. |
| `09-Rebuild-Inventory.ps1` | Records Windows software, basic hardware and storage details, with optional WinGet export. |
| `10-Privacy-Maintenance.ps1` | Previews or clears selected current-user Windows activity traces. |
| `11-Install-Privacy-Weekly.ps1` | Installs or removes a weekly Task Scheduler entry for the privacy cleaner. |

All numbered scripts live in the [`scripts/`](scripts/) directory. The [`Tabarc-Windows-Toolkit.ps1`](Tabarc-Windows-Toolkit.ps1) launcher sits at the repository root.

## Getting started

Use Windows PowerShell 5.1 or PowerShell 7 on Windows. Clone the repository, then run the scripts from its root folder.

```powershell
git clone https://github.com/TABARC-Code/windows-dev-scratchpad.git
cd windows-dev-scratchpad

# Quick file monitoring
.\scripts\02-Watch-File.ps1 -Path .\README.md

# Compare two existing folders without copying or deleting anything
.\scripts\04-Diff-Folders.ps1 -A 'C:\FolderA' -B 'D:\FolderB'

# Obtain a Windows rebuild inventory without WinGet
.\scripts\09-Rebuild-Inventory.ps1 -SkipWinGet
```

Replace the example paths with folders that exist on your computer. Most commands can run as an ordinary user. Some operations need Windows features or permissions appropriate to the job.

The HTTP server is the exception to the no-extra-dependencies idea: `01-Serve-Here.ps1` requires Python on your PATH. The rebuild inventory can use WinGet if it is installed. Neither is required for the rest of the local scratchpad.

## Weekly Windows privacy maintenance

Windows keeps recent-item records, thumbnails and clipboard data because those features are useful. They're also the sort of thing you might prefer not to retain indefinitely.

The privacy script deals with a deliberately limited set of these records. **It previews its actions unless you explicitly pass `-Apply`.**

```powershell
# See what the cleaner would do
.\scripts\10-Privacy-Maintenance.ps1

# Clear the default selection now
.\scripts\10-Privacy-Maintenance.ps1 -Apply

# Also attempt thumbnail and non-pinned clipboard-history cleanup
.\scripts\10-Privacy-Maintenance.ps1 -Apply -IncludeThumbnails -AttemptClipboardHistory
```

The default applied run removes shortcuts from the current user's Recent folder, requests that Windows clear Shell recent-use records, and empties the *current* clipboard. It does **not** delete the original documents.

Thumbnail cleaning is optional because Explorer can keep database files open. Clipboard-history cleaning is also best-effort: pinned entries are not removed by the Windows API, and scheduled sessions may not have access to that API.

There is no routine deletion of Prefetch, saved Wi-Fi profiles, USB device records or pinned Jump List databases. Repeatedly attacking those areas is a fairly reliable way to create extra work without gaining reliable privacy.

### Put it on a weekly schedule

First preview the Task Scheduler installation, then install it under your own signed-in Windows account:

```powershell
.\scripts\11-Install-Privacy-Weekly.ps1 -Install -WhatIf

# Every Sunday at 19:00, local computer time
.\scripts\11-Install-Privacy-Weekly.ps1 -Install -Day Sunday -Time '19:00'

# Uninstall the task
.\scripts\11-Install-Privacy-Weekly.ps1 -Uninstall
```

If you want optional thumbnail and clipboard-history attempts in the scheduled run, add `-IncludeThumbnails -AttemptClipboardHistory` to the install command.

The task only runs in the user's interactive session. Installing it here on GitHub does not schedule anything on your machine. Update the repository locally and run the installer once; reinstall the task if you move the script folder.

Applied-run summaries are written to `%LOCALAPPDATA%\TABARC\Privacy-Maintenance\weekly.jsonl`. The report records categories, counts and outcomes rather than clipboard contents or individual filenames.

**Read the [privacy-maintenance guide](docs/PRIVACY-MAINTENANCE.md) before enabling the weekly task.** This is housekeeping, not forensic erasure, and Windows may rebuild caches afterwards.

## Windows Toolkit launcher

I also wanted a single place to find the other little Windows tools scattered across my repositories, without merging them into a dependency-heavy package.

```powershell
# Show recognised tools and whether their files are installed
.\Tabarc-Windows-Toolkit.ps1 -Command list

# Examine the current display arrangement and foreground window
.\Tabarc-Windows-Toolkit.ps1 -Command ui

# Run a single network diagnostic pass
.\Tabarc-Windows-Toolkit.ps1 -Command network -AdapterName 'Wi-Fi'

# Compare two environment snapshots
.\Tabarc-Windows-Toolkit.ps1 -Command changes -Old 'C:\snapshots\old.json' -New 'C:\snapshots\new.json'
```

The launcher expects related TABARC-Code repositories in **sibling folders**, unless you supply `-RepositoriesRoot`. It reports missing utilities rather than installing them behind your back. Some commands, including `status`, `snapshot` and `emergency`, require their corresponding separate repositories.

The `emergency` command creates a diagnostic archive which can include private machine information. Check the contents before handing it to anyone.

## Folder snapshots and rebuilding a PC

Folder snapshots track file paths, sizes and modification times. They are useful for spotting changes but are **not** file backups, and the comparison isn't a cryptographic integrity check. Use the separate SHA-256 helper when you need a file hash.

The rebuild inventory produces a record of installed applications and system information, with a WinGet package export when available. It won't recover your documents, browser profiles, licences or every application's settings. It's a checklist for a reinstall, not a replacement for a backup.

## Testing, limits and security

GitHub Actions checks PowerShell syntax with Windows PowerShell 5.1 and PowerShell 7. Fixture tests cover the rebuild inventory and privacy cleaner, including preview versus applied operations on temporary directories. This is useful coverage; it does not prove that every script has been run against every version of Windows or every awkward live desktop.

A few ground rules:

- Keep your own backups before trying file-changing commands.
- Start with preview or dry-run options where available.
- Don't treat locally collected machine inventories or diagnostic logs as harmless public files.
- Read errors rather than assuming that a command which *ran* necessarily completed its intended work.
- Don't assume the privacy cleaner removes traces kept by browsers, applications, cloud backups or the filesystem.

There are more ideas in the [development plan](docs/WORKPLAN.md). I would rather finish a useful command properly than attach twelve impressive switches that nobody can trust.

## Licence

MIT. See [LICENSE](LICENSE).

Built and maintained under **TABARC-Code**.
