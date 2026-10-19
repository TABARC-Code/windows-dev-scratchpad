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
