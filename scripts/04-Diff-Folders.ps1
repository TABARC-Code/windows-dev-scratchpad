# TABARC-Code
# Folder diff using robocopy dry-run.
# Notes:
# - robocopy output is noisy. It always is.
# - This is a fast "what's different" view, not a cryptographic proof.

[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$A,
  [Parameter(Mandatory=$true)][string]$B,
  [string]$LogPath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

if (-not (Test-Path -LiteralPath $A)) { throw "Not found: $A" }
if (-not (Test-Path -LiteralPath $B)) { throw "Not found: $B" }

if (-not $LogPath) { $LogPath = Join-Path $PSScriptRoot "..\out\robocopy_diff.log" }
$logDir = Split-Path -Parent $LogPath
if ($logDir -and -not (Test-Path -LiteralPath $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

# /L dry run, /NJH /NJS reduces header spam, /NP no progress
robocopy "$A" "$B" /MIR /L /NJH /NJS /NP /R:0 /W:0 /LOG:"$LogPath"
Write-Host "Wrote $LogPath"
