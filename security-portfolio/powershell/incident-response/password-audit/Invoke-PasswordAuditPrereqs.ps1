<#
.SYNOPSIS
    Password audit prerequisites — enumerate AD accounts that need action.

.DESCRIPTION
    Queries Active Directory for enabled user accounts and flags any that meet
    one or more of:
      - PasswordNeverExpires is set
      - Password has exceeded the domain max-age policy
      - No logon within the last $DaysUntilStale days (stale account)

    Output is exported to a CSV at $ExportPath for review before running
    Invoke-PasswordAuditAction.ps1.

.PARAMETER DaysUntilStale
    Accounts with no logon in this many days are flagged as stale.
    Default: 90

.PARAMETER ExportPath
    Full path for the output CSV file.
    Default: .\PasswordAuditReport.csv

.NOTES
    Requires: RSAT ActiveDirectory module (Import-Module ActiveDirectory)
    Run as: Domain admin or delegated read account

.EXAMPLE
    .\Invoke-PasswordAuditPrereqs.ps1 -DaysUntilStale 60 -ExportPath C:\Audit\report.csv

.EXAMPLE
    .\Invoke-PasswordAuditPrereqs.ps1
    Uses defaults: stale threshold 90 days, output to .\PasswordAuditReport.csv
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [int]$DaysUntilStale = 90,

    [Parameter(Mandatory = $false)]
    [string]$ExportPath = '.\PasswordAuditReport.csv'
)

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host '[!] RSAT Active Directory module required. Install RSAT or run on a domain controller.' -ForegroundColor Red
    exit 1
}

Import-Module ActiveDirectory -ErrorAction Stop

Write-Host '[*] Fetching domain password policy...' -ForegroundColor Cyan
$DefaultPolicy = Get-ADDefaultDomainPasswordPolicy
$MaxAge        = $DefaultPolicy.MaxPasswordAge.Days

Write-Host "[*] Max password age from policy: $MaxAge days" -ForegroundColor Cyan
Write-Host '[*] Auditing user accounts...' -ForegroundColor Cyan

$StaleThreshold = (Get-Date).AddDays(-$DaysUntilStale)

$Users = Get-ADUser -Filter 'Enabled -eq $true' `
                    -Properties PasswordLastSet, PasswordNeverExpires, LastLogonDate, PasswordExpired

$Report = foreach ($User in $Users) {
    $NeedsAction = $false
    $Reason      = @()

    $Age = if ($User.PasswordLastSet) {
        (New-TimeSpan -Start $User.PasswordLastSet -End (Get-Date)).Days
    }
    else {
        9999 # password never set
    }

    if ($User.PasswordNeverExpires) {
        $NeedsAction = $true
        $Reason += 'PasswordNeverExpires set'
    }

    if ($MaxAge -ne 0 -and $Age -gt $MaxAge) {
        $NeedsAction = $true
        $Reason += "Password expired (age: $Age days)"
    }

    if ($null -ne $User.LastLogonDate -and $User.LastLogonDate -lt $StaleThreshold) {
        $NeedsAction = $true
        $Reason += "Stale account (no login > $DaysUntilStale days)"
    }

    if ($NeedsAction) {
        [PSCustomObject]@{
            SamAccountName    = $User.SamAccountName
            DistinguishedName = $User.DistinguishedName
            LastLogon         = $User.LastLogonDate
            PasswordLastSet   = $User.PasswordLastSet
            PasswordAgeDays   = $Age
            NeverExpires      = $User.PasswordNeverExpires
            AuditReason       = $Reason -join ' | '
        }
    }
}

if ($Report) {
    $Report | Export-Csv -Path $ExportPath -NoTypeInformation
    Write-Host "[+] Audit complete. Flagged $($Report.Count) account(s)." -ForegroundColor Green
    Write-Host "[+] Report saved: $ExportPath" -ForegroundColor White
}
else {
    Write-Host '[+] Audit complete. No accounts flagged.' -ForegroundColor Green
}
