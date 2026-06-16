<#
.SYNOPSIS
    Intune Proactive Remediation DETECTION — Google Chrome installation presence check.

.DESCRIPTION
    Verifies Google Chrome is installed by checking both the executable path and
    the ARP (Add/Remove Programs) registry entries. Exits 1 if Chrome is not found
    in both locations, which can indicate an orphaned or partially installed state.

    Exit codes:
      0 = Chrome present in ARP and on disk — do NOT remediate
      1 = Chrome absent or only partially detected
#>

$Apps  = (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall') |
             Get-ItemProperty | Select-Object DisplayName
$Apps += (Get-ChildItem 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall') |
             Get-ItemProperty | Select-Object DisplayName

$pathExists = (Test-Path "$env:ProgramFiles\Google\Chrome\Application\chrome.exe") -or
              (Test-Path "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe")

$inRegistry = $null -ne ($Apps | Where-Object DisplayName -EQ 'Google Chrome')

if ($pathExists -and $inRegistry) {
    Write-Output "Google Chrome detected"
    exit 0
}

Write-Output "Google Chrome not fully detected (path=$pathExists, registry=$inRegistry)"
exit 1
