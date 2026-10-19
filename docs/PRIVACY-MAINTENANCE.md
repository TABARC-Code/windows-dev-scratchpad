# Weekly Windows Privacy Maintenance

Current-user housekeeping for ordinary Windows activity traces. No registry history scrubbing, Wi-Fi key extraction, uninstall history manipulation or Prefetch deletion.

## What it does

By default, an applied run:

- Deletes .lnk shortcuts directly inside the signed-in user's Recent folder. It does not delete the documents they refer to.
- Invokes the documented Windows Shell API to request clearing recent/frequent usage lists. This does not delete all application histories, browser histories or pinned Jump Lists.
- Empties the current clipboard if accessible. This is different from the clipboard-history database.

Optional:
- -IncludeThumbnails: attempts to remove current-user thumbcache_*.db files. Explorer can hold some open; locked files are skipped and recorded as partial. Thumbnails regenerate as needed.
- -AttemptClipboardHistory: tries the supported Windows Runtime Clipboard.ClearHistory API. This may fail in a scheduled task or session without appropriate clipboard access. Pinned entries are not removed.

Always untouched: Prefetch, USBSTOR registry entries, saved Wi-Fi profiles/passwords, Jump List destination databases, browser history, original documents, Recycle Bin and application-specific caches.

**Not a secure erasure tool.** Previous copies may survive in backups, volume snapshots, synced copies or forensic disk remnants. Caches and MRU lists can regenerate.

## Manual use

The script previews intended actions by default. In PowerShell from the repository root:

    .\scripts\10-Privacy-Maintenance.ps1

Perform default housekeeping now:

    .\scripts\10-Privacy-Maintenance.ps1 -Apply

Also attempt thumbnail and clipboard-history cleanup:

    .\scripts\10-Privacy-Maintenance.ps1 -Apply -IncludeThumbnails -AttemptClipboardHistory

Native WhatIf preview:

    .\scripts\10-Privacy-Maintenance.ps1 -Apply -IncludeThumbnails -WhatIf

Use -SkipClipboard to preserve current clipboard contents; -SkipRecent and -SkipShellHistory control recent-use cleanup independently.

After an applied run, a small summary is appended to:

    %LOCALAPPDATA%\TABARC\Privacy-Maintenance\weekly.jsonl

The summary records category counts and statuses, not file names, clipboard contents, Wi-Fi passwords or USB identifiers.

## Weekly scheduling on your Windows PC

Run PowerShell as your ordinary signed-in Windows user, in the repository folder. Do not run the installer as SYSTEM or another account.

Preview the installation:

    .\scripts\11-Install-Privacy-Weekly.ps1 -Install -WhatIf

Install a weekly task for Sunday at 19:00 local computer time:

    .\scripts\11-Install-Privacy-Weekly.ps1 -Install -Day Sunday -Time '19:00'

Optional extras:

    .\scripts\11-Install-Privacy-Weekly.ps1 -Install -Day Sunday -Time '19:00' -IncludeThumbnails -AttemptClipboardHistory

Remove the weekly task:

    .\scripts\11-Install-Privacy-Weekly.ps1 -Uninstall

The task is called TABARC Weekly Privacy Maintenance. Reinstall with different flags to update it. The scheduled action calls the full path of the local script, so reinstall the task if you move the repository.

Task Scheduler uses the current Windows identity with interactive logon. It runs only in that user's session and does not request administrator privileges. If the PC is off or no user is logged on, a run may be missed or deferred. Confirm activity in Task Scheduler and the JSONL summary.

For routine disk-space maintenance, consider Windows Storage Sense. Disk Cleanup can provide a more complete thumbnail cleaning pass than direct deletion of cache databases held open by Explorer.

## Why other artefacts are preserved

- Prefetch: an OS-managed performance mechanism, not a complete diary of every programme run. Repeated deletion can impair startup speed and does not guarantee privacy.
- Wi-Fi profiles: forgetting networks can break automatic reconnection. Profile enumeration is not the same as access to the plaintext password.
- USB device history: registry entries help Windows identify and configure devices; blind removal can cause device-management problems.
- Jump List databases: deleting AutomaticDestinations and CustomDestinations files can erase pinned items.
- Clipboard history: current clipboard clearing is not Win+V history clearing. The Windows API does not clear pinned history entries.

## Validation and limitations

The automated fixtures use temporary Recent and thumbnail directories and do not erase real system history. Installer tests preview Task Scheduler without registering a task. Tests do not prove that locked caches, pinned data, clipboard history or individual application artefacts can always be cleared.

Supported by design on Windows PowerShell 5.1 and PowerShell 7 when relevant Windows APIs are accessible. The scheduled task uses Windows PowerShell 5.1 on Windows 10/11.

## Windows documentation

- https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shaddtorecentdocs
- https://learn.microsoft.com/en-us/uwp/api/windows.applicationmodel.datatransfer.clipboard.clearhistory
- https://support.microsoft.com/en-us/windows/experience/storage-filemanagement/manage-drive-space-with-storage-sense
- https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr
