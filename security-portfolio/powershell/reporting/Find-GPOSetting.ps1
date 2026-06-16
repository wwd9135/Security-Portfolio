<#
.SYNOPSIS
    Search all GPOs in the domain for a specific text pattern.

.DESCRIPTION
    Retrieves the XML report for every Group Policy Object in the domain and
    searches it for a provided string or regex pattern. Useful for auditing which
    GPOs configure a particular registry key, setting, or policy name.

    Output includes GPO display name, GUID, creation time, and last modified time.
    Use -ShowXmlMatch to also print the matching lines for debugging.

.PARAMETER Search
    The string or regex pattern to search for inside GPO XML reports.
    Default: EnableCertPaddingCheck

.PARAMETER ShowXmlMatch
    If specified, prints the matching XML line(s) under each found GPO.

.EXAMPLE
    .\Find-GPOSetting.ps1 -Search "EnableCertPaddingCheck"
    Finds all GPOs that configure the EnableCertPaddingCheck registry value.

.EXAMPLE
    .\Find-GPOSetting.ps1 -Search "Wintrust" -ShowXmlMatch
    Finds GPOs referencing Wintrust and shows the matching XML context.

.NOTES
    Requires: RSAT Group Policy Management tools (Get-GPO, Get-GPOReport)
    Run as: Domain user with read access to SYSVOL
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Search = 'EnableCertPaddingCheck',

    [switch]$ShowXmlMatch
)

Write-Host "[*] Searching all GPOs for pattern: '$Search'..." -ForegroundColor Cyan
Write-Host ''

$gpos  = Get-GPO -All
$total = $gpos.Count
$index = 0

foreach ($gpo in $gpos) {
    $index++
    Write-Progress -Activity 'Scanning GPOs...' `
                   -Status   "Processing $index of $total $($gpo.DisplayName)" `
                   -PercentComplete (($index / $total) * 100)

    try {
        $xml = Get-GPOReport -Guid $gpo.Id -ReportType Xml -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to retrieve report for GPO: $($gpo.DisplayName)"
        continue
    }

    if ($xml -match $Search) {
        Write-Host "[+] Found match in GPO: $($gpo.DisplayName)" -ForegroundColor Green
        Write-Host "    GUID     : $($gpo.Id)"
        Write-Host "    Created  : $($gpo.CreationTime)"
        Write-Host "    Modified : $($gpo.ModificationTime)"

        if ($ShowXmlMatch) {
            Write-Host '    Matching XML lines:' -ForegroundColor Yellow
            ($xml -split "`n") | Select-String -Pattern $Search | ForEach-Object {
                Write-Host "      $_"
            }
        }

        Write-Host '---------------------------------------------'
    }
}

Write-Host ''
Write-Host '[+] Search complete.' -ForegroundColor Cyan
