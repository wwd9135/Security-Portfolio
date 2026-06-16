# Ensure AD Module is loaded
if (!(Get-Module -ListAvailable ActiveDirectory)) {
    Write-Host "[!] RSAT Active Directory module required." -ForegroundColor Red
    return
}

Write-Host "[*] Fetching Password Policy..." -ForegroundColor Cyan
$DefaultPolicy = Get-ADDefaultDomainPasswordSettings
$MaxAge = $DefaultPolicy.MaxPasswordAge.Days

Write-Host "[*] Auditing User Accounts..." -ForegroundColor Cyan

$Users = Get-ADUser -Filter 'Enabled -eq $true' -Properties PasswordLastSet, PasswordNeverExpires, LastLogonDate, PasswordExpired

$Report = foreach ($User in $Users) {
    $NeedsAction = $false
    $Reason = @()

    # Calculate Password Age
    if ($User.PasswordLastSet) {
        $Age = (New-TimeSpan -Start $User.PasswordLastSet -End (Get-Date)).Days
    } else {
        $Age = 9999 # Never set
    }

    # Logic Gates for Audit
    if ($User.PasswordNeverExpires) {
        $NeedsAction = $true
        $Reason += "PasswordNeverExpires Set"
    }
    if ($Age -gt $MaxAge -and $MaxAge -ne 0) {
        $NeedsAction = $true
        $Reason += "Password Expired (Age: $Age days)"
    }
    if ($User.LastLogonDate -lt (Get-Date).AddDays(-$DaysUntilStale) -and $User.LastLogonDate -ne $null) {
        $NeedsAction = $true
        $Reason += "Stale Account (No login > $DaysUntilStale days)"
    }

    if ($NeedsAction) {
        [PSCustomObject]@{
            SamAccountName      = $User.SamAccountName
            DistinguishedName   = $User.DistinguishedName
            LastLogon           = $User.LastLogonDate
            PasswordLastSet     = $User.PasswordLastSet
            PasswordAgeDays     = $Age
            NeverExpires        = $User.PasswordNeverExpires
            AuditReason         = $Reason -join " | "
        }
    }
}

# --- Export & Summary ---
if ($Report) {
    $Report | Export-Csv -Path $ExportPath -NoTypeInformation
    Write-Host "[+] Audit Complete. Flagged $($Report.Count) accounts." -ForegroundColor Green
    Write-Host "[+] Report Saved: $ExportPath" -ForegroundColor White
} else {
    Write-Host "[+] Audit Complete. No accounts flagged." -ForegroundColor Green
}