# TABARC-Code
# Quick SHA256 hash for a file.

[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Path)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
