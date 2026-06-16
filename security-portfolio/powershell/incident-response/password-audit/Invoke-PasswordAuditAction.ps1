<#
.SYNOPSIS
    Password audit action — force password change for flagged AD accounts.

.DESCRIPTION
    Reads a list of SamAccountNames from a CSV (produced by Invoke-PasswordAuditPrereqs.ps1
    or exported from the SIEM), cross-references Active Directory, and sets
    ChangePasswordAtLogon on all accounts whose password was last set on or before
    the audit date.

    Accounts not found in AD are recorded as removed/deleted.
    Failed updates are collected and reported at the end.

.PARAMETER UserListFile
    Path to a CSV or text file containing one SamAccountName per line.
    Default: .\data.csv

.PARAMETER AuditDate
    Only accounts whose PasswordLastSet is on or before this date are actioned.
    Accepts any datetime string. Default: yesterday (run date minus 1 day).

.PARAMETER OutputPath
    Directory for the ChangedAccounts.csv output file.
    Default: .\

.NOTES
    Requires: RSAT ActiveDirectory module
    Run as: Account with permission to set ChangePasswordAtLogon

.EXAMPLE
    .\Invoke-PasswordAuditAction.ps1 -UserListFile .\flagged-users.csv -AuditDate "2025-10-01"

.EXAMPLE
    .\Invoke-PasswordAuditAction.ps1
    Uses defaults: data.csv, yesterday as audit cutoff, output to current directory.
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory = $false)]
    [string]$UserListFile = '.\data.csv',

    [Parameter(Mandatory = $false)]
    [datetime]$AuditDate = (Get-Date).AddDays(-1),

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = '.\'
)

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host '[!] RSAT Active Directory module required.' -ForegroundColor Red
    exit 1
}

Import-Module ActiveDirectory -ErrorAction Stop

if (-not (Test-Path $UserListFile)) {
    Write-Host "[!] User list file not found: $UserListFile" -ForegroundColor Red
    exit 1
}

Write-Host "[*] Reading user list from: $UserListFile" -ForegroundColor Cyan
Write-Host "[*] Audit date cutoff: $($AuditDate.ToString('yyyy-MM-dd'))" -ForegroundColor Cyan

$usernames = Get-Content -Path $UserListFile

$removed = @()
$change  = @()

foreach ($username in $usernames) {
    $username = $username.Trim()
    if ([string]::IsNullOrWhiteSpace($username)) { continue }

    $u = Get-ADUser -Filter { SamAccountName -eq $username } -ErrorAction SilentlyContinue
    if ($null -eq $u) {
        $removed += $username
    }
    else {
        $change += $username
    }
}

Write-Host "[*] Found in AD: $($change.Count) | Not found (removed): $($removed.Count)" -ForegroundColor Cyan

$UsersToChange = $change | ForEach-Object {
    Get-ADUser -Identity $_ -Properties DisplayName, PasswordLastSet, PasswordNeverExpires |
        Where-Object { $_.PasswordLastSet -le $AuditDate }
} | Sort-Object DisplayName

Write-Host '[*] Accounts to action (PasswordLastSet on or before audit date):'
$UsersToChange | Select-Object DisplayName, PasswordLastSet, PasswordNeverExpires | Format-Table -AutoSize

$outputFile = Join-Path $OutputPath 'ChangedAccounts.csv'
$UsersToChange | Export-Csv -Path $outputFile -NoTypeInformation
Write-Host "[+] Account list exported: $outputFile" -ForegroundColor White

$failed = @()
foreach ($user in $UsersToChange) {
    if ($PSCmdlet.ShouldProcess($user.SamAccountName, 'Set ChangePasswordAtLogon')) {
        try {
            Set-ADUser -Identity $user -ChangePasswordAtLogon $true -ErrorAction Stop
            Write-Host "Updated: $($user.SamAccountName)" -ForegroundColor Green
        }
        catch {
            $failed += $user.SamAccountName
            Write-Host "FAILED: $($user.SamAccountName) — $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

if ($removed.Count -gt 0) {
    Write-Output "`nAccounts not found in AD (may have been removed):"
    $removed | ForEach-Object { Write-Output "  $_" }
}

if ($failed.Count -gt 0) {
    Write-Warning "Failed to update $($failed.Count) account(s) — investigate: $($failed -join ', ')"
    exit 1
}

Write-Host '[+] Password audit action complete.' -ForegroundColor Green
exit 0
