# TABARC-Code
# Local export of Windows software and hardware details for a manual rebuild.
[CmdletBinding()]
param(
  [string]$OutRoot = (Join-Path $PSScriptRoot '..\out\rebuild'),
  [switch]$SkipWinGet,
  [switch]$IncludeNetwork
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$folder = Join-Path ([IO.Path]::GetFullPath($OutRoot)) ("inventory_" + $stamp)
New-Item -ItemType Directory -Path $folder -Force | Out-Null

$uninstallKeys = @(
  'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$apps = @()
foreach ($key in $uninstallKeys) {
  $apps += @(Get-ItemProperty -Path $key -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName } |
    Select-Object @{n='name';e={$_.DisplayName}},@{n='version';e={$_.DisplayVersion}},@{n='publisher';e={$_.Publisher}})
}
$apps = @($apps | Sort-Object name,version -Unique)

$system = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
$os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
$volumes = @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' |
  Select-Object DeviceID,VolumeName,Size,FreeSpace,FileSystem)
$network = @()
if ($IncludeNetwork) {
  $network = @(Get-NetIPConfiguration -ErrorAction Stop |
    Select-Object InterfaceAlias,InterfaceDescription,IPv4Address,IPv6Address,IPv4DefaultGateway,DNSServer)
}

$inventory = [ordered]@{
  capturedAt = (Get-Date).ToUniversalTime().ToString('o')
  computer = $env:COMPUTERNAME
  operatingSystem = [ordered]@{
    caption = $os.Caption
    version = $os.Version
    build = $os.BuildNumber
    architecture = $os.OSArchitecture
  }
  hardware = [ordered]@{
    manufacturer = $system.Manufacturer
    model = $system.Model
    physicalMemoryBytes = $system.TotalPhysicalMemory
  }
  applications = $apps
  volumes = $volumes
  networkIncluded = [bool]$IncludeNetwork
  network = $network
}

$inventoryFile = Join-Path $folder 'inventory.json'
$inventory | ConvertTo-Json -Depth 10 |
  Set-Content -LiteralPath $inventoryFile -Encoding UTF8

$wingetStatus = 'skipped'
$wingetFile = Join-Path $folder 'winget-packages.json'
if (-not $SkipWinGet) {
  $winget = Get-Command winget -ErrorAction SilentlyContinue
  if ($winget) {
    try {
      & $winget.Source export -o $wingetFile --accept-source-agreements | Out-Null
      if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $wingetFile -PathType Leaf)) {
        $wingetStatus = 'exported'
      } else {
        $wingetStatus = 'failed'
      }
    } catch {
      $wingetStatus = 'failed'
      Write-Warning "WinGet export failed: $($_.Exception.Message)"
    }
  } else {
    $wingetStatus = 'not-installed'
  }
}
if ($wingetStatus -eq 'failed' -and (Test-Path -LiteralPath $wingetFile)) {
  Remove-Item -LiteralPath $wingetFile -Force
}

$notes = @(
  '# Windows Rebuild Inventory'
  ''
  "Captured: $($inventory.capturedAt)"
  ''
  '## Contents'
  ''
  '- inventory.json: installed software, OS, machine and disk metadata.'
  "- WinGet export: $wingetStatus"
  ''
  '## Restoration'
  ''
  '1. Review the JSON files and confirm which applications are still wanted.'
  '2. Back up personal documents and application settings separately.'
  '3. Reinstall Windows and review drivers, encryption and device settings.'
  '4. Import WinGet packages only after reviewing the package list.'
  '5. Restore application settings manually and verify each application.'
  ''
  'This is a planning inventory, not a full computer backup.'
  'No accounts, passwords or licence keys were intentionally exported.'
  'The inventory contains machine and software information; keep it private.'
)
if ($wingetStatus -eq 'exported') {
  $notes += ''
  $notes += 'After reviewing the file, you can use:'
  $notes += ''
  $notes += '    winget import -i winget-packages.json --accept-package-agreements'
}
$notes | Set-Content -LiteralPath (Join-Path $folder 'REBUILD.md') -Encoding UTF8

Write-Host "Created Windows rebuild inventory: $folder"
[pscustomobject]@{ Folder=$folder; Inventory=$inventoryFile; WinGet=$wingetStatus }
