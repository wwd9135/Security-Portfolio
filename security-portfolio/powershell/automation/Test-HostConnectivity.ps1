<#
.SYNOPSIS
    Pings a list of managed devices from an Excel export and reports which are reachable.

.DESCRIPTION
    Reads an Excel file (produced by the Defender KQL compliance queries) that contains
    DeviceName and IPAddresses columns. For each device it selects the best private IPv4
    address, runs a single ICMP ping, and outputs a reachability table.

    Skips link-local (169.254.x.x) and public addresses in favour of RFC1918 ranges.
    Requires the ImportExcel module (Install-Module ImportExcel).

.PARAMETER Path
    Path to the Excel file containing DeviceName and IPAddresses columns.
    Defaults to 'IPAddresses.xlsx' in the current directory.

.EXAMPLE
    .\Test-HostConnectivity.ps1

.EXAMPLE
    .\Test-HostConnectivity.ps1 -Path "C:\exports\devices.xlsx"

.NOTES
    Requires: ImportExcel module
    Install-Module ImportExcel -Scope CurrentUser
    The IPAddresses column must contain JSON-formatted IP objects as exported
    by the DeviceNetworkInfo Defender KQL query.
#>

[CmdletBinding()]
param(
    [string]$Path = "IPAddresses.xlsx"
)

if (-not (Test-Path $Path)) {
    Write-Error "File not found: $Path"
    return
}

$rows = Import-Excel -Path $Path
Write-Host "Found $($rows.Count) device(s) in $Path" -ForegroundColor Cyan

$results = foreach ($row in $rows) {
    $device  = $row.DeviceName
    $rawJson = $row.IPAddresses
    $bestIp  = $null
    $reason  = "Unknown"

    if ([string]::IsNullOrWhiteSpace($rawJson)) {
        $reason = "Empty IP cell"
    }
    else {
        try {
            $cleanJson = $rawJson.Replace([char]0x201C, '"').Replace([char]0x201D, '"').Trim()
            $ipObjects = $cleanJson | ConvertFrom-Json

            # Prefer private IPv4; skip link-local
            $bestIpObj = $ipObjects |
                Where-Object { $_.IPAddress -like '*.*' -and $_.IPAddress -notlike '169.254.*' } |
                Sort-Object { $_.AddressType -eq 'Private' } -Descending |
                Select-Object -First 1

            if ($bestIpObj) {
                $bestIp = $bestIpObj.IPAddress
            }
            else {
                $reason = "No suitable IPv4"
            }
        }
        catch {
            $reason = "JSON parse error"
        }
    }

    if ($bestIp) {
        if (Test-Connection $bestIp -Count 1 -Quiet -ErrorAction SilentlyContinue) {
            $reason    = "Reachable"
            $reachable = $true
        }
        else {
            $reason    = "No reply"
            $reachable = $false
        }
    }
    else {
        $reachable = $false
    }

    [pscustomobject]@{
        DeviceName = $device
        ChosenIP   = $bestIp
        Reachable  = $reachable
        Reason     = $reason
    }
}

if ($results) {
    $results | Sort-Object Reachable | Format-Table -AutoSize
}
else {
    Write-Warning "No results. Verify that Excel headers are exactly 'DeviceName' and 'IPAddresses'."
}
