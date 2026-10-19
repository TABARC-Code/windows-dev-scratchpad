# TABARC-Code
# Current-user Windows activity housekeeping. No Prefetch, Wi-Fi or USB device changes.
[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [switch]$Apply,
  [switch]$SkipRecent,
  [switch]$SkipShellHistory,
  [switch]$SkipClipboard,
  [switch]$AttemptClipboardHistory,
  [switch]$IncludeThumbnails,
  [string]$RecentDirectory = (Join-Path $env:APPDATA 'Microsoft\Windows\Recent'),
  [string]$ThumbnailDirectory = (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Explorer'),
  [string]$ReportPath = (Join-Path $env:LOCALAPPDATA 'TABARC\Privacy-Maintenance\weekly.jsonl')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') { throw 'This script requires Windows.' }

$results = New-Object 'System.Collections.Generic.List[object]'
$dryRun = (-not $Apply -or [bool]$WhatIfPreference)

function Record-Result([string]$area,[string]$status,[int]$count,[string]$note) {
  $script:results.Add([pscustomobject]@{
    area = $area
    status = $status
    count = $count
    note = $note
  })
}

# Deleting entries here removes shortcuts, not the original documents.
if (-not $SkipRecent) {
  if (Test-Path -LiteralPath $RecentDirectory -PathType Container) {
    $recentLinks = @(Get-ChildItem -LiteralPath $RecentDirectory -File -Filter '*.lnk' -Force -ErrorAction Stop)
    $removed = 0
    $failed = 0
    foreach ($link in $recentLinks) {
      if ($dryRun) { continue }
      if ($PSCmdlet.ShouldProcess('Current-user Recent shortcut', 'Delete shortcut')) {
        try {
          Remove-Item -LiteralPath $link.FullName -Force -ErrorAction Stop
          $removed++
        } catch { $failed++ }
      }
    }
    if ($dryRun) {
      Record-Result 'recent-shortcuts' 'preview' $recentLinks.Count 'Original documents are not modified.'
    } else {
      Record-Result 'recent-shortcuts' $(if ($failed) { 'partial' } else { 'cleared' }) $removed "Failed items: $failed."
    }
  } else {
    Record-Result 'recent-shortcuts' 'not-found' 0 'No current-user Recent folder was found.'
  }
}

# Use the documented Shell API, not deletion of Jump List databases.
if (-not $SkipShellHistory) {
  if ($dryRun) {
    Record-Result 'shell-recent-usage' 'preview' 0 'Windows Shell recent/frequent usage lists would be cleared.'
  } elseif ($PSCmdlet.ShouldProcess('Current-user Shell usage data', 'Clear recent/frequent records')) {
    try {
      if (-not ('TabarcPrivacyShell' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class TabarcPrivacyShell {
  [DllImport("shell32.dll")]
  public static extern void SHAddToRecentDocs(uint flags, IntPtr item);
}
'@ -ErrorAction Stop
      }
      [TabarcPrivacyShell]::SHAddToRecentDocs(0,[IntPtr]::Zero)
      Record-Result 'shell-recent-usage' 'requested' 0 'Windows Shell API invoked; individual application histories are not covered.'
    } catch {
      Record-Result 'shell-recent-usage' 'failed' 0 'Windows Shell API could not be invoked.'
    }
  }
}

# Clear only the *current* clipboard object. History requires a different API.
if (-not $SkipClipboard) {
  if ($dryRun) {
    Record-Result 'current-clipboard' 'preview' 0 'Current clipboard would be emptied (not clipboard history).'
  } elseif ($PSCmdlet.ShouldProcess('Current-user clipboard', 'Empty clipboard')) {
    try {
      if (-not ('TabarcPrivacyClipboard' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class TabarcPrivacyClipboard {
  [DllImport("user32.dll")] public static extern bool OpenClipboard(IntPtr owner);
  [DllImport("user32.dll")] public static extern bool EmptyClipboard();
  [DllImport("user32.dll")] public static extern bool CloseClipboard();
}
'@ -ErrorAction Stop
      }
      $success = $false
      for ($attempt=0; $attempt -lt 3; $attempt++) {
        if ([TabarcPrivacyClipboard]::OpenClipboard([IntPtr]::Zero)) {
          try { $success = [TabarcPrivacyClipboard]::EmptyClipboard() }
          finally { [void][TabarcPrivacyClipboard]::CloseClipboard() }
          break
        }
        Start-Sleep -Milliseconds 150
      }
      if ($success) {
        Record-Result 'current-clipboard' 'cleared' 1 'Clipboard content emptied.'
      } else {
        Record-Result 'current-clipboard' 'failed' 0 'Clipboard was busy or unavailable.'
      }
    } catch {
      Record-Result 'current-clipboard' 'failed' 0 'Clipboard could not be accessed in this user session.'
    }
  }
}

# Optional, best-effort WinRT history clearing. Pinned entries survive by design.
if ($AttemptClipboardHistory) {
  if ($dryRun) {
    Record-Result 'clipboard-history' 'preview' 0 'Would attempt Windows clipboard history API; pinned entries survive.'
  } elseif ($PSCmdlet.ShouldProcess('Current-user clipboard history','Clear non-pinned history')) {
    try {
      $winrt = [Windows.ApplicationModel.DataTransfer.Clipboard, Windows.ApplicationModel.DataTransfer, ContentType=WindowsRuntime]
      $ok = $winrt::ClearHistory()
      if ($ok) {
        Record-Result 'clipboard-history' 'cleared' 1 'Non-pinned history cleared; pinned items remain.'
      } else {
        Record-Result 'clipboard-history' 'unavailable' 0 'Clipboard history API returned false.'
      }
    } catch {
      Record-Result 'clipboard-history' 'unavailable' 0 'History API not accessible in this session; use Win+V to clear it manually.'
    }
  }
}

# Optional best-effort thumbnail DB housekeeping. Explorer may keep files open.
if ($IncludeThumbnails) {
  if (Test-Path -LiteralPath $ThumbnailDirectory -PathType Container) {
    $thumbs = @(Get-ChildItem -LiteralPath $ThumbnailDirectory -File -Filter 'thumbcache_*.db' -Force -ErrorAction Stop)
    $removed = 0
    $failed = 0
    foreach ($thumb in $thumbs) {
      if ($dryRun) { continue }
      if ($PSCmdlet.ShouldProcess('Current-user Explorer thumbnail cache', 'Delete cache database')) {
        try {
          Remove-Item -LiteralPath $thumb.FullName -Force -ErrorAction Stop
          $removed++
        } catch { $failed++ }
      }
    }
    if ($dryRun) {
      Record-Result 'thumbnail-cache' 'preview' $thumbs.Count 'Some thumbnail databases may be locked when the cleaner runs.'
    } else {
      Record-Result 'thumbnail-cache' $(if ($failed) { 'partial' } else { 'cleared' }) $removed "Failed/locked items: $failed. Thumbnail caches will regenerate."
    }
  } else {
    Record-Result 'thumbnail-cache' 'not-found' 0 'No current-user Explorer cache folder was found.'
  }
} else {
  Record-Result 'thumbnail-cache' 'disabled' 0 'Optional; see Storage Sense or Disk Cleanup.'
}

# Explicit non-goals. No sensitive identifiers or Wi-Fi keys appear in the log.
Record-Result 'prefetch' 'preserved' 0 'Windows-managed performance data untouched.'
Record-Result 'wifi-profiles' 'preserved' 0 'Saved Wi-Fi connections and keys untouched.'
Record-Result 'usb-history' 'preserved' 0 'Device registry history untouched.'
Record-Result 'jump-list-databases' 'preserved' 0 'Pinned Jump Lists are not manually deleted.'

$report = [pscustomobject]@{
  timestamp = (Get-Date).ToUniversalTime().ToString('o')
  mode = $(if ($dryRun) { 'preview' } else { 'apply' })
  results = @($results.ToArray())
}

foreach ($item in $results) {
  Write-Host ("{0}: {1} ({2}) - {3}" -f $item.area,$item.status,$item.count,$item.note)
}

if (-not $dryRun -and $ReportPath) {
  try {
    $parent = Split-Path -Parent ([IO.Path]::GetFullPath($ReportPath))
    if (-not (Test-Path -LiteralPath $parent)) {
      New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $compact = $report | ConvertTo-Json -Depth 6 -Compress
    Add-Content -LiteralPath $ReportPath -Value $compact -Encoding UTF8 -ErrorAction Stop
    Write-Host 'Saved a summary without file names or clipboard contents.'
  } catch {
    Write-Warning 'The maintenance log could not be written.'
  }
}

$report
