# DCU BIOS Auto-Update - Proactive Remediation DETECTION
# -------------------------------------------------------------------
# Exit 0 = HEALTHY  (key present, parseable, and < 14 days old) -> do NOT remediate
# Exit 1 = UNHEALTHY (key missing, empty, unparseable, stale, or future-dated) -> RUN remediation
#
# Identical logic to the driver detection. This is the fix for the predicted
# regression: now that the BIOS PSADT actually stamps the key, the old
# hardcoded-en-GB / fail-open parser would have made BIOS stop re-running on the
# 14-day cycle in exactly the same way the driver pipeline already did.
#
# The PSADT SetRegKey writer MUST stamp in the matching format:
#   (Get-Date).ToString('s')   e.g. 2026-06-04T15:30:45

$RegPath     = 'HKLM:\SOFTWARE\DELL'
$RegName     = 'DCUAutoBIOSUpdatesLastRun'
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
