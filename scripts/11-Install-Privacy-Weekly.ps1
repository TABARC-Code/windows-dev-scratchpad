# TABARC-Code
# Install or remove an ordinary weekly current-user Task Scheduler entry.
[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [switch]$Install,
  [switch]$Uninstall,
  [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')]
  [string]$Day = 'Sunday',
  [ValidatePattern('^(?:[01][0-9]|2[0-3]):[0-5][0-9]$')]
  [string]$Time = '19:00',
  [switch]$IncludeThumbnails,
  [switch]$AttemptClipboardHistory,
  [switch]$SkipClipboard,
  [switch]$SkipRecent,
  [ValidatePattern('^[A-Za-z0-9 _.-]+$')]
  [string]$TaskName = 'TABARC Weekly Privacy Maintenance'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([bool]$Install -eq [bool]$Uninstall) {
  throw 'Choose exactly one of -Install or -Uninstall.'
}
if ($env:OS -ne 'Windows_NT') { throw 'Windows Task Scheduler is required.' }

if ($Uninstall) {
  if ($PSCmdlet.ShouldProcess($TaskName,'Unregister weekly maintenance task')) {
    $existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existing) {
      Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
      Write-Host "Removed: $TaskName"
    } else {
      Write-Host "Task not installed: $TaskName"
    }
  }
  return
}

$scriptPath = Join-Path $PSScriptRoot '10-Privacy-Maintenance.ps1'
if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
  throw "Maintenance script not found beside installer: $scriptPath"
}

$runner = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
if (-not (Test-Path -LiteralPath $runner -PathType Leaf)) {
  throw 'Windows PowerShell executable was not found.'
}
$arguments = @(
  '-NoLogo','-NoProfile','-NonInteractive',
  '-ExecutionPolicy','RemoteSigned',
  '-WindowStyle','Hidden',
  '-File', ('"{0}"' -f $scriptPath),
  '-Apply'
)
if ($IncludeThumbnails) { $arguments += '-IncludeThumbnails' }
if ($AttemptClipboardHistory) { $arguments += '-AttemptClipboardHistory' }
if ($SkipClipboard) { $arguments += '-SkipClipboard' }
if ($SkipRecent) {
  $arguments += '-SkipRecent'
  $arguments += '-SkipShellHistory'
}

$when = [DateTime]::ParseExact($Time,'HH:mm',[Globalization.CultureInfo]::InvariantCulture)
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $Day -At $when
$action = New-ScheduledTaskAction -Execute $runner -Argument ($arguments -join ' ')
$principal = New-ScheduledTaskPrincipal -UserId ([Security.Principal.WindowsIdentity]::GetCurrent().Name) -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 20)

Write-Host "Scheduled day/time: $Day $Time (local Windows time)"
Write-Host 'Runs only as the signed-in current user; no administrator privileges requested.'
Write-Host 'If not logged on, clipboard operations cannot run in your interactive desktop session.'
if ($AttemptClipboardHistory) {
  Write-Warning 'Clipboard history clearing is best-effort. Pinned entries are not removed by the Windows API.'
}
if ($IncludeThumbnails) {
  Write-Warning 'Live Explorer thumbnail caches may remain locked and will be regenerated.'
}
if ($PSCmdlet.ShouldProcess($TaskName,'Register weekly task for current user')) {
  Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force -ErrorAction Stop | Out-Null
  Write-Host "Installed weekly scheduled task: $TaskName"
}
