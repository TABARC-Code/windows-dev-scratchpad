$ErrorActionPreference = 'Stop'
$root = Join-Path ([IO.Path]::GetTempPath()) ('rebuild-test-' + [guid]::NewGuid().ToString('N'))
try {
  $result = & (Join-Path $PSScriptRoot '..\scripts\09-Rebuild-Inventory.ps1') -OutRoot $root -SkipWinGet
  if (-not (Test-Path -LiteralPath $result.Inventory -PathType Leaf)) { throw 'Inventory JSON missing.' }
  if ($result.WinGet -ne 'skipped') { throw 'WinGet unexpectedly ran.' }
  $inventory = Get-Content -LiteralPath $result.Inventory -Raw | ConvertFrom-Json
  if (-not $inventory.operatingSystem.version -or -not $inventory.hardware.model) { throw 'System details missing.' }
  if (-not (Test-Path -LiteralPath (Join-Path $result.Folder 'REBUILD.md'))) { throw 'Rebuild guide missing.' }
  $launcher = & (Join-Path $PSScriptRoot '..\Tabarc-Windows-Toolkit.ps1') -Command list
  if (-not @($launcher | Where-Object { $_.Utility -eq 'rebuild-inventory' -and $_.Installed }).Count) {
    throw 'Launcher does not see the local inventory script.'
  }
  Write-Host 'Rebuild Inventory smoke test passed.'
} finally {
  Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction SilentlyContinue
}
