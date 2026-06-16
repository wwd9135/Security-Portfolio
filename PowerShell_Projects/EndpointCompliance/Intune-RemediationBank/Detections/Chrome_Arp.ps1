$Apps  = (Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall) | 
             Get-ItemProperty | Select-Object DisplayName
$Apps += (Get-ChildItem HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall) | 
             Get-ItemProperty | Select-Object DisplayName

$pathExists = (Test-Path "$env:ProgramFiles\Google\Chrome\Application\chrome.exe") -or 
              (Test-Path "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe")

$inRegistry = $null -ne ($Apps | Where-Object DisplayName -EQ "Google Chrome")

if ($pathExists -and $inRegistry) {
    Write-Host "Google Chrome detected"
    Exit 0
} else {
    Exit 1
}