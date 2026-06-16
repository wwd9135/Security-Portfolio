$RegPath = 'HKLM:\SOFTWARE\DELL'
$RegName = 'DCUAutoDriverUpdatesLastRun'

if (Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue) {
    $LastRunDateString = (Get-ItemProperty -Path $RegPath -Name $RegName).$RegName
    
    try {
        # Parse full datetime using UK culture
        $LastRunDate = [datetime]::Parse($LastRunDateString, [System.Globalization.CultureInfo]::GetCultureInfo('en-GB'))
    } catch {
        #Write-Host "Invalid date format in registry."
        exit 0
    }

    $DaysSinceRun = (Get-Date) - $LastRunDate

    if ($DaysSinceRun.TotalDays -ge 14) {
        Write-Host "Two weeks have passed. Proceed to Remediation."
        exit 1
    } else {
        Write-Host "Less than two weeks. Skip Remediation."
        exit 0
    }
} else {
    Write-Host "Registry key not found. Proceed."
    exit 1
}