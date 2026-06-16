$RegPath = 'HKLM:\SOFTWARE\DELL'
$RegName = 'DCUAutoDriverUpdatesLastRun'

# Check if the value exists
if (Test-Path $RegPath) {
    $valueExists = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue
    if ($valueExists) {
        try {
            #Remove the registry value
            Remove-ItemProperty -Path $RegPath -Name $RegName
            Write-Output "Successfully removed '$RegName' from '$RegPath'."
        } catch {
            Write-Error "Failed to remove '$RegName': $_"
        }
    } else {
        Write-Output "'$RegName' does not exist at '$RegPath'."
    }
} else {
    Write-Output "Registry path '$RegPath' does not exist."
}