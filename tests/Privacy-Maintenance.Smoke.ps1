# Exercise preview, fixture cleanup, and the non-destructive scheduler preview.
$ErrorActionPreference = 'Stop'
$root = Join-Path ([IO.Path]::GetTempPath()) ('tabarc-privacy-' + [guid]::NewGuid().ToString('N'))
$recent = Join-Path $root 'Recent'
$thumb = Join-Path $root 'Explorer'
$log = Join-Path $root 'summary.jsonl'
New-Item -ItemType Directory -Path $recent,$thumb -Force | Out-Null
try {
  'shortcut fixture' | Set-Content -LiteralPath (Join-Path $recent 'sample.lnk')
  'keep this' | Set-Content -LiteralPath (Join-Path $recent 'keep.txt')
  'thumb fixture' | Set-Content -LiteralPath (Join-Path $thumb 'thumbcache_256.db')
  'other data' | Set-Content -LiteralPath (Join-Path $thumb 'other.db')
  $scriptPath = Join-Path $PSScriptRoot '..\scripts\10-Privacy-Maintenance.ps1'
  $params = @{
    RecentDirectory = $recent
    ThumbnailDirectory = $thumb
    IncludeThumbnails = $true
    SkipShellHistory = $true
    SkipClipboard = $true
    ReportPath = $log
  }
  $preview = & $scriptPath @params
  if ($preview.mode -ne 'preview') { throw 'Preview mode missing.' }
  if (-not (Test-Path -LiteralPath (Join-Path $recent 'sample.lnk'))) { throw 'Preview removed recent link.' }
  if (-not (Test-Path -LiteralPath (Join-Path $thumb 'thumbcache_256.db'))) { throw 'Preview removed thumbnail cache.' }
  if (Test-Path -LiteralPath $log) { throw 'Preview wrote a log.' }

  $applied = & $scriptPath @params -Apply
  if ($applied.mode -ne 'apply') { throw 'Apply mode missing.' }
  if (Test-Path -LiteralPath (Join-Path $recent 'sample.lnk')) { throw 'Recent shortcut was not removed.' }
  if (Test-Path -LiteralPath (Join-Path $thumb 'thumbcache_256.db')) { throw 'Thumbnail cache was not removed.' }
  if (-not (Test-Path -LiteralPath (Join-Path $recent 'keep.txt'))) { throw 'Unrelated recent file was removed.' }
  if (-not (Test-Path -LiteralPath (Join-Path $thumb 'other.db'))) { throw 'Unrelated cache file was removed.' }
  if (-not (Test-Path -LiteralPath $log)) { throw 'Expected summary log.' }
  $report = Get-Content -LiteralPath $log -First 1 | ConvertFrom-Json
  if ($report.mode -ne 'apply') { throw 'Summary contents invalid.' }

  $installer = Join-Path $PSScriptRoot '..\scripts\11-Install-Privacy-Weekly.ps1'
  & $installer -Install -Day Sunday -Time '19:00' -WhatIf | Out-Null
  Write-Host 'Privacy Maintenance fixture test passed.'
} finally {
  Remove-Item -LiteralPath $root -Force -Recurse -ErrorAction SilentlyContinue
}
