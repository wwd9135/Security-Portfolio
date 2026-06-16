<#
.SYNOPSIS
    Advanced Windows Update Compatibility & Failure Diagnostic Script.
    Run as Administrator.
#>

$ErrorActionPreference = "SilentlyContinue"
$Report = @()

Write-Host "--- Starting Windows Update Diagnostic ---" -ForegroundColor Cyan

# 1. Check Core Services
$Services = @("wuauserv", "bits", "cryptsvc", "trustedinstaller")
foreach ($Svc in $Services) {
    $Status = Get-Service $Svc
    if ($Status.Status -ne "Running") {
        Write-Host "[!] Warning: $($Svc) is $($Status.Status)" -ForegroundColor Yellow
    } else {
        Write-Host "[OK] $($Svc) is active." -ForegroundColor Green
    }
}

# 2. Check Disk Space & System Reserved
$Drive = Get-PSDrive C | Select-Object Used, Free
if ($Drive.Free -lt 10GB) {
    Write-Host "[!] Low Disk Space: Only $($Drive.Free / 1GB) GB left. Updates may fail." -ForegroundColor Red
}

# 3. Query Windows Update Agent Log for specific HRESULT Errors
Write-Host "`n--- Scanning Update Logs for Recent Failures ---" -ForegroundColor Cyan
$Events = Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-WindowsUpdateClient'; Id=20} -MaxEvents 5
foreach ($Event in $Events) {
    $ErrorCode = ([xml]$Event.ToXml()).Event.EventData.Data | Where-Object { $_.Name -eq 'ErrorCode' } | Select-Object -ExpandProperty '#text'
    $UpdateTitle = ([xml]$Event.ToXml()).Event.EventData.Data | Where-Object { $_.Name -eq 'UpdateTitle' } | Select-Object -ExpandProperty '#text'
    
    Write-Host "Failure detected in: $UpdateTitle" -ForegroundColor Gray
    Write-Host "Hex Error Code: $ErrorCode" -ForegroundColor Red
    
    # Common Error Translation
    switch ($ErrorCode) {
        "0x80244017" { Write-Host " -> Cause: Proxy/Firewall blocking connection." }
        "0x80070005" { Write-Host " -> Cause: Access Denied (Permissions issue)." }
        "0x80070422" { Write-Host " -> Cause: Update service is disabled." }
        "0x80073712" { Write-Host " -> Cause: Component store is corrupt (Run DISM)." }
    }
}

# 4. Check Component Store Health (CBS)
Write-Host "`n--- Checking Component Store (SFC/DISM Status) ---" -ForegroundColor Cyan
$RepairState = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing" -Name "EnableAssessment"
if ($null -eq $RepairState) {
    Write-Host "[i] No pending repair flags found in registry." -ForegroundColor Gray
}

# 5. Check for Pending Reboots
$RebootPending = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
if ($RebootPending) {
    Write-Host "[!] A reboot is pending. Updates will not install until restart." -ForegroundColor Yellow
}

Write-Host "`n--- Diagnostic Complete ---" -ForegroundColor Cyan
