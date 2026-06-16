# DCU Driver Auto-Update - Proactive Remediation DETECTION
# -------------------------------------------------------------------
# Exit 0 = HEALTHY  (key present, parseable, and < 14 days old) -> do NOT remediate
# Exit 1 = UNHEALTHY (key missing, empty, unparseable, stale, or future-dated) -> RUN remediation
#
# Design notes:
#  * Timestamps are read with InvariantCulture using an EXACT sortable format,
#    so this never depends on whether the process culture is en-GB (user) or
#    en-US (SYSTEM/.DEFAULT under Intune). The PSADT SetRegKey writer MUST stamp
#    in the same format:  (Get-Date).ToString('s')  e.g. 2026-06-04T15:30:45
#  * FAIL CLOSED: anything we cannot positively confirm as "fresh" returns 1 so
#    remediation refreshes the stamp. This also self-heals any legacy key written
#    in the old ambiguous 'Get-Date -Format G' format the first time it runs.
#  * The catch logs (previously commented out) so a parse failure is visible in
#    the Intune Proactive Remediation output.

$RegPath     = 'HKLM:\SOFTWARE\DELL'
$RegName     = 'DCUAutoDriverUpdatesLastRun'
$MaxAgeDays  = 14
$StampFormat = 's'   # ISO 8601 sortable, culture-invariant. Must match the PSADT writer.

# --- Read the heartbeat value -------------------------------------------------
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

# --- Parse strictly with InvariantCulture ------------------------------------
[datetime]$LastRunDate = [datetime]::MinValue
$parsed = [datetime]::TryParseExact(
    $LastRunString,
    $StampFormat,
    [System.Globalization.CultureInfo]::InvariantCulture,
    [System.Globalization.DateTimeStyles]::None,
    [ref]$LastRunDate)

if (-not $parsed) {
    # Old/ambiguous format (e.g. a 'Get-Date -Format G' string written under a
    # different culture). Do NOT trust it - fail closed so remediation rewrites
    # it cleanly on the next cycle.
    Write-Host "Heartbeat value '$LastRunString' is not in expected invariant format ('$StampFormat'). Remediate."
    exit 1
}

# --- Evaluate freshness -------------------------------------------------------
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

Write-Host "Heartbeat is fresh (< $MaxAgeDays days). Healthy - skip remediation."
exit 0
