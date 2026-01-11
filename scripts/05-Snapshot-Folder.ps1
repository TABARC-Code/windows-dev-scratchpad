# TABARC-Code
# Snapshot folder file list (recursive) to JSON.
# Notes:
# - If you point this at C:\Windows, that's on you.

[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Path,
  [string]$OutDir = "$PSScriptRoot\..\out"
)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

if (-not (Test-Path -LiteralPath $Path)) { throw "Not found: $Path" }
if (-not (Test-Path -LiteralPath $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

$ts = Get-Date -Format "yyyyMMdd_HHmmss"
$out = Join-Path $OutDir ("snapshot_{0}.json" -f $ts)

$items = Get-ChildItem -LiteralPath $Path -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
  [pscustomobject]@{
    path = $_.FullName
    size = $_.Length
    lastWriteUtc = $_.LastWriteTimeUtc.ToString("o")
  }
}

$data = [ordered]@{
  time=(Get-Date).ToString("o")
  root=(Resolve-Path -LiteralPath $Path).Path
  count=$items.Count
  files=$items
}

$data | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $out -Encoding UTF8
Write-Host "Wrote $out"
