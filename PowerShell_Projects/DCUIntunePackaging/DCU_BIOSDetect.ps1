$RegPath = 'HKLM:\SOFTWARE\DELL'
$RegName = 'DCUAutoBIOSUpdatesLastRun'

if (Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue) {
    $LastRunDateString = (Get-ItemProperty -Path $RegPath -Name $RegName).$RegName

    try {
        # Parse full datetime using UK culture
        $LastRunDate = [datetime]::Parse($LastRunDateString, [System.Globalization.CultureInfo]::GetCultureInfo('en-GB'))
    } catch {
        Write-Host "Invalid date format in registry."
        
    }

    $DaysSinceRun = (Get-Date) - $LastRunDate

    if ($DaysSinceRun.TotalDays -ge 14) {
        Write-Host "Two weeks have passed. Proceed to Remediation."
       
    } else {
        Write-Host "Less than two weeks. Skip Remediation."
       
    }
} else {
    Write-Host "Registry key not found. Proceed."

}