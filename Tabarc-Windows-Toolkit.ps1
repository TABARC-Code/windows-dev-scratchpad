# TABARC-Code
# One entry point for standalone Windows utilities stored in sibling repositories.
[CmdletBinding()]
param(
  [ValidateSet('list','status','snapshot','changes','emergency','eventlog','port')][string]$Command = 'list',
  [string]$RepositoriesRoot = '',
  [string]$Old = '',
  [string]$New = '',
  [ValidateSet('System','Application','Security')][string]$LogName = 'System',
  [ValidateRange(0,65535)][int]$Port = 0
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $RepositoriesRoot) {
  $RepositoriesRoot = Split-Path -Parent $PSScriptRoot
}
$RepositoriesRoot = [IO.Path]::GetFullPath($RepositoriesRoot)

$catalogue = [ordered]@{
  'environment-snapshot' = @('windows-env-drift-auditor-redo','Snapshot-Env.ps1')
  'change-detective' = @('windows-env-drift-auditor-redo','Change-Detective.ps1')
  'tool-check' = @('windows-env-drift-auditor-redo','Check-Tools.ps1')
  'disk-space' = @('windows-disk-space-warn','Disk-Space-Warn.ps1')
  'emergency-dump' = @('windows-emergency-toolkit','Invoke-Emergency-Dump.ps1')
  'event-log-diff' = @('windows-eventlog-diff','EventLog-Diff.ps1')
  'port-owner' = @('windows-port-warden','Who-Owns-Port.ps1')
}

function Script-Path([string]$id) {
  if (-not $catalogue.Contains($id)) { throw "Unknown utility: $id" }
  $details = $catalogue[$id]
  Join-Path (Join-Path $RepositoriesRoot $details[0]) $details[1]
}
function Run-Utility([string]$id,[object[]]$arguments=@()) {
  $path = Script-Path $id
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    throw "Utility '$id' not installed at $path. Clone its repository next to this one or set -RepositoriesRoot."
  }
  & $path @arguments
}

switch ($Command) {
  'list' {
    foreach ($name in $catalogue.Keys) {
      $path = Script-Path $name
      [pscustomobject]@{
        Utility = $name
        Installed = (Test-Path -LiteralPath $path -PathType Leaf)
        Path = $path
      }
    }
  }
  'status' {
    Write-Host 'Tool availability:'
    Run-Utility 'tool-check'
    Write-Host 'Disk-space warnings (no output means none were found):'
    Run-Utility 'disk-space'
  }
  'snapshot' {
    Run-Utility 'environment-snapshot'
  }
  'changes' {
    if (-not $Old -or -not $New) { throw 'The changes command requires both -Old and -New snapshot paths.' }
    Run-Utility 'change-detective' @('-Old',$Old,'-New',$New)
  }
  'emergency' {
    Write-Warning 'This creates a diagnostic ZIP with potentially private system details. Review it before sharing.'
    Run-Utility 'emergency-dump'
  }
  'eventlog' {
    Run-Utility 'event-log-diff' @('-LogName',$LogName)
  }
  'port' {
    if ($Port -lt 1) { throw 'The port command requires -Port between 1 and 65535.' }
    Run-Utility 'port-owner' @('-Port',$Port)
  }
}
