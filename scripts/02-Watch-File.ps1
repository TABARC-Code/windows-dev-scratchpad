# TABARC-Code
# Watches a file for changes and prints last write time + size.
# Tiny, boring, and that's the point.

[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Path,
  [int]$IntervalMs = 500
)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

if (-not (Test-Path -LiteralPath $Path)) { throw "Not found: $Path" }

$last = (Get-Item -LiteralPath $Path).LastWriteTimeUtc
while($true){
  Start-Sleep -Milliseconds $IntervalMs
  $i = Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue
  if (-not $i) { Write-Host "Deleted: $Path"; break }
  if ($i.LastWriteTimeUtc -ne $last){
    $last = $i.LastWriteTimeUtc
    Write-Host ("Changed {0} size={1} bytes" -f $i.LastWriteTime, $i.Length)
  }
}
