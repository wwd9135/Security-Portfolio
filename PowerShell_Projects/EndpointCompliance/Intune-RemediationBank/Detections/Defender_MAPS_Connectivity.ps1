# 3. MAPS Connectivity
$MpCmdRun = "$Env:ProgramFiles\Windows Defender\MpCmdRun.exe"
if (-not (Test-Path $MpCmdRun)) {
    Write-Host "FAIL: MpCmdRun.exe not found at $MpCmdRun"
    exit 1
}

$Output    = & $MpCmdRun -ValidateMapsConnection 2>&1
$ExitCode  = $LASTEXITCODE
$OutputStr = ($Output -join " ").Trim()

# Hard pass: clean exit code AND confirmed success string in output
if ($ExitCode -eq 0 -and $OutputStr -imatch "successfully established a connection") {
    Write-Host "PASS: MAPS connectivity verified successfully"
    exit 0
}

# Everything else is a genuine failure — surface the real output for diagnosis
Write-Host "FAIL: MAPS connectivity check failed. Exit code: $ExitCode"
Write-Host "Output: $OutputStr"
exit 1