# windows-dev-scratchpad

A curated pile of small PowerShell helpers you keep rewriting.
They’re standalone, but they live together so you stop scattering them across random folders. Thats the idea.

Author: TABARC-Code  
Plugin URI: https://github.com/TABARC-Code/

## What’s in here

- serve this folder (Python simple server wrapper)
- watch that file/folder
- diff folders (robocopy dry-run wrapper)
- log what changed since last snapshot
- quick hashes, tail logs, that sort of thing

No frameworks. No dependencies beyond Windows + PowerShell.
Sometimes Python, if you choose the serve scripts.

## Scripts

- `01-Serve-Here.ps1`
- `02-Watch-File.ps1`
- `03-Watch-Folder.ps1`
- `04-Diff-Folders.ps1`
- `05-Snapshot-Folder.ps1`
- `06-What-Changed.ps1`
- `07-Tail-Log.ps1`
- `08-Quick-Hash.ps1`

## Quick start

```powershell
.\scripts\01-Serve-Here.ps1 -AutoPort -OpenBrowser
.\scripts\02-Watch-File.ps1 -Path .\notes.txt
.\scripts\04-Diff-Folders.ps1 -A C:\A -B C:\B
```

If you’re expecting perfection: you’re new here.


## Windows Toolkit Launcher

`Tabarc-Windows-Toolkit.ps1` gives a single entry point for selected standalone Windows utilities. Clone the repositories as sibling folders, or pass the directory containing them with `-RepositoriesRoot`.


```powershell
.\Tabarc-Windows-Toolkit.ps1 -Command list
.\Tabarc-Windows-Toolkit.ps1 -Command status
.\Tabarc-Windows-Toolkit.ps1 -Command snapshot
.\Tabarc-Windows-Toolkit.ps1 -Command changes -Old C:\snapshots\old.json -New C:\snapshots\new.json
.\Tabarc-Windows-Toolkit.ps1 -Command eventlog -LogName System
.\Tabarc-Windows-Toolkit.ps1 -Command port -Port 8000
```

The optional `emergency` command creates a diagnostic archive; review it before sharing. The launcher does not download or install missing tools or escalate privileges.

See `docs/WORKPLAN.md` for implemented and proposed work.


## Windows Rebuild Inventory

`scripts/09-Rebuild-Inventory.ps1` creates a local inventory of installed software, OS and hardware details, storage volumes and optionally network configuration. Where WinGet is available, it also exports a package list for later review.


```powershell
.\scripts\09-Rebuild-Inventory.ps1 -SkipWinGet
.\scripts\09-Rebuild-Inventory.ps1 -OutRoot 'D:\MyInventory'
.\Tabarc-Windows-Toolkit.ps1 -Command rebuild
```

This is **not** a full Windows backup and does not restore data, credentials or application settings. Its reports contain potentially identifiable system details; keep them local and review before sharing.


Additional launcher commands:


```powershell
.\Tabarc-Windows-Toolkit.ps1 -Command network -AdapterName 'Wi-Fi'
.\Tabarc-Windows-Toolkit.ps1 -Command ui
```

The network command performs **one diagnostic pass only**. It does not reset network adapters. The UI command reports screen geometry and the foreground window without changing anything.


## Weekly privacy maintenance

Use scripts/10-Privacy-Maintenance.ps1 for a dry-run preview of current-user Recent shortcuts, Shell recent-use records and current clipboard. Add -Apply to perform cleanup; add -IncludeThumbnails and -AttemptClipboardHistory for optional, best-effort extras.

Install an ordinary current-user weekly scheduled task with:

    .\scripts\11-Install-Privacy-Weekly.ps1 -Install -Day Sunday -Time '19:00'

Remove it with:

    .\scripts\11-Install-Privacy-Weekly.ps1 -Uninstall

Prefetch, Wi-Fi profiles, USB history and pinned Jump List databases are not modified. Read docs/PRIVACY-MAINTENANCE.md before enabling the task.
