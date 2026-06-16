$RegPath = 'HKLM:\SOFTWARE\DELL'
$RegName = 'DCUAutoDriverUpdatesLastRun'

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
# DCU Driver Auto-Update - Proactive Remediation DETECTION  (en-GB, 64-bit hive forced)
# -------------------------------------------------------------------
# ROOT CAUSE this fixes: the app writes the heartbeat to the NATIVE 64-bit
# HKLM\SOFTWARE\DELL, but an Intune PR runs 32-bit by default, where that path is
# redirected to HKLM\SOFTWARE\WOW6432Node\DELL (empty) - so detection saw "absent",
# reported healthy, and never remediated. We open the 64-bit view explicitly so it
# does not matter whether the PR host is 32- or 64-bit.
#
# Exit 0 = HEALTHY (no remediation):  key absent, OR present + parses + < 14 days.
# Exit 1 = REMEDIATE (delete key so the app re-runs): present + stale / unparseable / future.

$RegSubKey  = 'SOFTWARE\DELL'
$RegName    = 'DCUAutoDriverUpdatesLastRun'
$MaxAgeDays = 14
$Culture    = [System.Globalization.CultureInfo]::GetCultureInfo('en-GB')

# Read from the 64-bit view regardless of this process's bitness.
$base = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
$key  = $base.OpenSubKey($RegSubKey)
$val  = if ($key) { $key.GetValue($RegName) } else { $null }

if ($null -eq $val) {
    Write-Host "Heartbeat '$RegName' not present (64-bit view). Nothing to remediate; the app re-creates it. Healthy."
    write-host 0
}

[datetime]$LastRun = [datetime]::MinValue
$ok = [datetime]::TryParse([string]$val, $Culture, [System.Globalization.DateTimeStyles]::None, [ref]$LastRun)

if (-not $ok) {
    Write-Host "Heartbeat value '$val' could not be parsed (en-GB). Clear it so the app re-stamps. Remediate."
    write-host 1
}

$age = ((Get-Date) - $LastRun).TotalDays
Write-Host ("Heartbeat: {0:yyyy-MM-dd HH:mm:ss}; age {1:N1} day(s)." -f $LastRun, $age)

if ($age -lt 0)           { Write-Host "Future-dated (clock skew/bad data). Clear it. Remediate."}
if ($age -ge $MaxAgeDays) { Write-Host "Stale (>= $MaxAgeDays days). Clear it so the app re-runs. Remediate." }

Write-Host "Fresh (< $MaxAgeDays days). Healthy - skip remediation."
write-host "Healthy"

