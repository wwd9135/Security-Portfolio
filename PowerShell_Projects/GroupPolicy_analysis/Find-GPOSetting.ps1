
<#
.SYNOPSIS
    Searches all GPOs in the domain for a specific text string 
    within their XML reports.

.DESCRIPTION
    This script scans every Group Policy Object and inspects its XML 
    report for a provided search pattern (default: EnableCertPaddingCheck).
    Useful for identifying which GPOs configure certain registry keys,
    settings, or policies.

.PARAMETER Search
    The string or regex pattern to search for inside GPO XML reports.

.PARAMETER ShowXmlMatch
    Optional switch to display the matching line(s) for debugging.

.EXAMPLE
    ./Find-GPOSetting.ps1 -Search "EnableCertPaddingCheck"

.EXAMPLE
    ./Find-GPOSetting.ps1 -Search "Wintrust" -ShowXmlMatch

.NOTES
    Author: William Richardson
    Requires: RSAT / Group Policy Management tools installed
#>

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [string]$Search = "EnableCertPaddingCheck",

    [switch]$ShowXmlMatch
)

Write-Host "🔍 Searching all GPOs for pattern: '$Search'..." -ForegroundColor Cyan
Write-Host ""

# Retrieve GPO list
$gpos = Get-GPO -All
$total = $gpos.Count
$index = 0

foreach ($gpo in $gpos) {
    $index++
    Write-Progress -Activity "Scanning GPOs..." `
                   -Status "Processing $index of $total $($gpo.DisplayName)" `
                   -PercentComplete (($index / $total) * 100)

    try {
        $xml = Get-GPOReport -Guid $gpo.Id -ReportType Xml -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to retrieve report for GPO: $($gpo.DisplayName)"
        continue
    }

    if ($xml -match $Search) {
        Write-Host "✔ Found match in GPO: $($gpo.DisplayName)" -ForegroundColor Green
        Write-Host "   GUID: $($gpo.Id)"
        Write-Host "   Created: $($gpo.CreationTime)"
        Write-Host "   Modified: $($gpo.ModificationTime)"
        
        if ($ShowXmlMatch) {
            Write-Host "   Matching XML lines:" -ForegroundColor Yellow
            ($xml -split "`n") | Select-String -Pattern $Search | ForEach-Object {
                Write-Host "     $_"
            }
        }

        Write-Host "---------------------------------------------"
    }
}

Write-Host ""
Write-Host "✅ Search complete." -ForegroundColor Cyan
