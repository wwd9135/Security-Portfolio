<#
.SYNOPSIS
    Forces "User must change password at next logon" for a list of AD accounts,
    then writes a CSV report recording the outcome for every account.

.DESCRIPTION
    Reads SamAccountNames from a text file (one per line) and, for each one:
      1. Confirms the account exists in Active Directory.
      2. Skips it if its password was changed AFTER the audit cutoff date.
      3. Otherwise sets ChangePasswordAtLogon = $true.
    A live status is printed to the console (the "CLI feed"), and a single CSV
    report is produced with a Status of Succeeded / Failed / Skipped / NotFound
    (or WhatIf during a dry run) plus a reason for every input account.

.PARAMETER InputFile
    Path to a text file containing one SamAccountName per line.

.PARAMETER ReportPath
    Path for the output CSV results report.

.PARAMETER AuditDate
    Cutoff date. Accounts whose PasswordLastSet is AFTER this date are skipped
    (i.e. they already changed their password since the audit, so leave them alone).
    

.EXAMPLE
    # Dry run - shows what WOULD happen, changes nothing
    .\Set-ChangePwdAtLogon.ps1 -InputFile .\AccountsToChange.txt -ReportPath .\results.csv -WhatIf

.EXAMPLE
    # Real run
    .\Set-ChangePwdAtLogon.ps1 -InputFile "C:\Scripts\Password_audit\cmpd1\AccountsToChange.txt" `
                               -ReportPath "C:\Scripts\Password_audit\cmpd1\results.csv" `
                               -AuditDate '2026-05-01'
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$InputFile,

    [Parameter(Mandatory)]
    [string]$ReportPath,

    [datetime]$AuditDate = '2026-05-01' # CHANGE THIS IF NEED BE.
)

# --- Setup ---------------------------------------------------------------
Import-Module ActiveDirectory -ErrorAction Stop

if (-not (Test-Path -LiteralPath $InputFile)) {
    throw "Input file not found: $InputFile"
}

# Read names, trim whitespace, drop blank lines and duplicates
$usernames = Get-Content -LiteralPath $InputFile |
    ForEach-Object { $_.Trim() } |
    Where-Object   { $_ -ne '' } |
    Select-Object  -Unique

if (-not $usernames) {
    throw "No usernames found in $InputFile"
}

Write-Host "Loaded $($usernames.Count) username(s) from $InputFile" -ForegroundColor Cyan
Write-Host ("Audit cutoff: {0:yyyy-MM-dd} (passwords changed AFTER this are skipped)`n" -f $AuditDate) -ForegroundColor Cyan

# One result object is collected for EVERY input name, whatever the outcome
$results = [System.Collections.Generic.List[object]]::new()

# --- Main loop (single AD pass per user) ---------------------------------
foreach ($name in $usernames) {

    # 1. Does the account exist?
    $user = Get-ADUser -Filter "SamAccountName -eq '$name'" `
                       -Properties DisplayName, PasswordLastSet, PasswordNeverExpires `
                       -ErrorAction SilentlyContinue

    if (-not $user) {
        Write-Host "NOT FOUND : $name" -ForegroundColor DarkYellow
        $results.Add([pscustomobject]@{
            SamAccountName       = $name
            DisplayName          = ''
            PasswordLastSet      = ''
            PasswordNeverExpires = ''
            Status               = 'NotFound'
            Detail               = 'No matching AD account'
        })
        continue
    }

    # 2. Password changed since the audit? -> skip (leave them alone)
    if ($null -ne $user.PasswordLastSet -and $user.PasswordLastSet -gt $AuditDate) {
        Write-Host "SKIPPED   : $($user.SamAccountName) (password set $($user.PasswordLastSet))" -ForegroundColor Gray
        $results.Add([pscustomobject]@{
            SamAccountName       = $user.SamAccountName
            DisplayName          = $user.DisplayName
            PasswordLastSet      = $user.PasswordLastSet
            PasswordNeverExpires = $user.PasswordNeverExpires
            Status               = 'Skipped'
            Detail               = 'Password changed after audit date'
        })
        continue
    }

    # 3. Apply the remediation
    $status = $null
    $detail = ''
    try {
        if ($PSCmdlet.ShouldProcess($user.SamAccountName, 'Set ChangePasswordAtLogon = $true')) {
            Set-ADUser -Identity $user -ChangePasswordAtLogon $true -ErrorAction Stop
            Write-Host "SUCCEEDED : $($user.SamAccountName)" -ForegroundColor Green
            $status = 'Succeeded'
        }
        else {
            # -WhatIf was supplied
            Write-Host "WHATIF    : $($user.SamAccountName) (no change made)" -ForegroundColor DarkCyan
            $status = 'WhatIf'
            $detail = 'Dry run - no change made'
        }
    }
    catch {
        Write-Host "FAILED    : $($user.SamAccountName) - $($_.Exception.Message)" -ForegroundColor Red
        $status = 'Failed'
        $detail = $_.Exception.Message
    }

    $results.Add([pscustomobject]@{
        SamAccountName       = $user.SamAccountName
        DisplayName          = $user.DisplayName
        PasswordLastSet      = $user.PasswordLastSet
        PasswordNeverExpires = $user.PasswordNeverExpires
        Status               = $status
        Detail               = $detail
    })
}

# --- Report --------------------------------------------------------------
$results | Sort-Object Status, DisplayName |
    Export-Csv -LiteralPath $ReportPath -NoTypeInformation -Encoding UTF8

Write-Host "`n================ SUMMARY ================" -ForegroundColor Cyan
$results | Group-Object Status | Sort-Object Name | ForEach-Object {
    Write-Host ("  {0,-10} : {1}" -f $_.Name, $_.Count)
}
Write-Host ("  {0,-10} : {1}" -f 'TOTAL', $results.Count)
Write-Host "Report written to: $ReportPath" -ForegroundColor Cyan