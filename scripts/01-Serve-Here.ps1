# TABARC-Code
# Serve current folder via python -m http.server.
# Notes:
# - This is the "I just need to preview something" button.
# - AutoPort exists because something is always camping on 8000.

[CmdletBinding()]
param(
  [int]$Port = 8000,
  [switch]$AutoPort,
  [string]$Bind = "127.0.0.1",
  [switch]$OpenBrowser
)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
  throw "Python not found on PATH."
}

function Test-PortFree([int]$p,[string]$b){
  try {
    $l=[System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse($b),$p)
    $l.Start(); $l.Stop(); $true
  } catch { $false }
}

if ($AutoPort) {
  for($i=0;$i -lt 50;$i++){
    if (Test-PortFree $Port $Bind) { break }
    $Port++
  }
}

$here=(Get-Location).Path
$url="http://$Bind`:$Port"
Write-Host "Serving: $here"
Write-Host "URL: $url"
if($OpenBrowser){ Start-Process $url }

Push-Location $here
try { python -m http.server $Port --bind $Bind } finally { Pop-Location }
