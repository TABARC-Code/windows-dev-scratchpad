# TABARC-Code
# Tail a file. PowerShell has Get-Content -Wait, but this wraps it with sane defaults.

[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$Path,
  [int]$Lines = 50
)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

Get-Content -LiteralPath $Path -Tail $Lines -Wait
