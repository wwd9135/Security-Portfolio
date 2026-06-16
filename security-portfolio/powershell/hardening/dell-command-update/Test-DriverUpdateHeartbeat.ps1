<#
.SYNOPSIS
    Intune Proactive Remediation DETECTION — DCU driver auto-update heartbeat check.

.DESCRIPTION
    Reads a registry heartbeat value stamped by the driver update Win32 app
    (Invoke-DriverUpdatePackage.ps1). If the value is missing, empty, unparseable,
    stale (>= 14 days old), or future-dated, exits 1 to trigger remediation.
    Otherwise exits 0 (healthy).

    Designed to be deployed as the Detection script of an Intune Proactive Remediation
    paired with Invoke-DriverUpdateRemediation.ps1.

    Fail-closed design: anything that cannot be confirmed as a fresh, valid timestamp
    returns 1. This also self-heals legacy keys written in ambiguous locale-dependent
    formats on the first remediation cycle.

    Exit codes:
      0 = Healthy — heartbeat present and fresh, do NOT remediate
      1 = Unhealthy — remediation should run

.NOTES
    Registry path : HKLM:\SOFTWARE\DELL\DCUAutoDriverUpdatesLastRun
    Timestamp format: ISO 8601 sortable 's' format, written with InvariantCulture.
    The paired Win32 app MUST stamp in exactly this format: (Get-Date).ToString('s')
#>

$RegPath     = 'HKLM:\SOFTWARE\DELL'
$RegName     = 'DCUAutoDriverUpdatesLastRun'
$MaxAgeDays  = 14
$StampFormat = 's'   # ISO 8601 sortable, culture-invariant — must match the package writer

# Read heartbeat value
try {
    $prop          = Get-ItemProperty -Path $RegPath -Name $RegName -ErrorAction Stop
    $LastRunString = [string]$prop.$RegName
}
catch {
    Write-Host "Heartbeat '$RegName' not found at '$RegPath'. Remediate."
    exit 1
}

if ([string]::IsNullOrWhiteSpace($LastRunString)) {
    Write-Host "Heartbeat '$RegName' is present but empty. Remediate."
    exit 1
}

# Parse strictly with InvariantCulture — never trust locale-dependent parsing
[datetime]$LastRunDate = [datetime]::MinValue
$parsed = [datetime]::TryParseExact(
    $LastRunString,
    $StampFormat,
    [System.Globalization.CultureInfo]::InvariantCulture,
    [System.Globalization.DateTimeStyles]::None,
    [ref]$LastRunDate)

if (-not $parsed) {
    # Old/ambiguous format (e.g. 'Get-Date -Format G' written under a different process culture).
    # Fail closed so remediation rewrites it cleanly on the next cycle.
    Write-Host "Heartbeat '$LastRunString' is not in expected format ('$StampFormat'). Remediate."
    exit 1
}

# Evaluate freshness
$DaysSinceRun = ((Get-Date) - $LastRunDate).TotalDays
Write-Host ("Heartbeat parsed OK: {0:yyyy-MM-dd HH:mm:ss}; age {1:N1} day(s)." -f $LastRunDate, $DaysSinceRun)

if ($DaysSinceRun -lt 0) {
    Write-Host "Heartbeat is in the future (clock skew or bad data). Remediate."
    exit 1
}

if ($DaysSinceRun -ge $MaxAgeDays) {
    Write-Host "Heartbeat is stale (>= $MaxAgeDays days). Remediate."
    exit 1
}

Write-Host "Heartbeat is fresh (< $MaxAgeDays days). Healthy."
exit 0
