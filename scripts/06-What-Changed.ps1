# TABARC-Code
# Compare two folder snapshots produced by 05-Snapshot-Folder.ps1

[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Old,
  [Parameter(Mandatory=$true)][string]$New
)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

function Load([string]$p){
  if (-not (Test-Path -LiteralPath $p)) { throw "Not found: $p" }
  Get-Content -Raw -LiteralPath $p | ConvertFrom-Json
}

$o = Load $Old
$n = Load $New

$omap = @{}
foreach($f in $o.files){ $omap[$f.path] = $f }
$nmap = @{}
foreach($f in $n.files){ $nmap[$f.path] = $f }

$added = @()
$removed = @()
$changed = @()

foreach($k in $nmap.Keys){
  if (-not $omap.ContainsKey($k)){ $added += $k; continue }
  $a=$omap[$k]; $b=$nmap[$k]
  if ($a.size -ne $b.size -or $a.lastWriteUtc -ne $b.lastWriteUtc){ $changed += $k }
}
foreach($k in $omap.Keys){
  if (-not $nmap.ContainsKey($k)){ $removed += $k }
}

Write-Host "Added:   $($added.Count)"
Write-Host "Removed: $($removed.Count)"
Write-Host "Changed: $($changed.Count)"
if($added.Count){ Write-Host ""; Write-Host "Added:"; $added | Select-Object -First 50 | ForEach-Object { Write-Host ("  + {0}" -f $_) } }
if($removed.Count){ Write-Host ""; Write-Host "Removed:"; $removed | Select-Object -First 50 | ForEach-Object { Write-Host ("  - {0}" -f $_) } }
if($changed.Count){ Write-Host ""; Write-Host "Changed:"; $changed | Select-Object -First 50 | ForEach-Object { Write-Host ("  * {0}" -f $_) } }
