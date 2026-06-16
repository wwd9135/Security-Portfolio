$RegPath = 'HKLM:\SOFTWARE\DELL'
$RegName = 'DCUAutoBIOSUpdatesLastRun'

# Check if the registry key and value exist
if (Test-Path $RegPath) {
    $value = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
    if ($null -ne $value.$RegName) {
        # Registry value exists
        Write-host "It exists"
        exit 0
    } else {
        # Registry value does not exist
        Write-host "It does not exist"
        exit 1
    }
} else {
    # Registry path does not exist
    Write-host "It does not exist"
    exit 1
}
