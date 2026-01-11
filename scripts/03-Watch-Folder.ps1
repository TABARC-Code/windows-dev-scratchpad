# TABARC-Code
# Watches a folder (non-recursive) for file count changes.
# It’s not fancy. It’s meant to be quick.

[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Path,
  [int]$IntervalMs = 1000
)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

if (-not (Test-Path -LiteralPath $Path)) { throw "Not found: $Path" }

$last = (Get-ChildItem -LiteralPath $Path -File -ErrorAction SilentlyContinue).Count
Write-Host "Watching $Path (files=$last)"
while($true){
  Start-Sleep -Milliseconds $IntervalMs
  $cur = (Get-ChildItem -LiteralPath $Path -File -ErrorAction SilentlyContinue).Count
  if ($cur -ne $last){
    Write-Host ("File count changed: {0} -> {1}" -f $last, $cur)
    $last = $cur
  }
}
