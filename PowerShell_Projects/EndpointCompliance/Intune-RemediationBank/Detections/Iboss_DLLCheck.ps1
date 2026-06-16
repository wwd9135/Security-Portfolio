# Force 64-bit Program Files even when script runs in 32-bit Intune context
$ProgramFiles64 = ${env:ProgramW6432}

$IbsaDLL = "$ProgramFiles64\Phantom\IBSA\ibsa.dll"
$MinVersion = [version]'6.5.253.0'

if (-not (Test-Path $IbsaDLL)) {
    Exit 1 # DLL not found, not installed
}
$CurrentVersion = [version](Get-Item $IbsaDLL).VersionInfo.FileVersionRaw
if ($CurrentVersion -lt $MinVersion) {
    Exit 1
}
Exit 0