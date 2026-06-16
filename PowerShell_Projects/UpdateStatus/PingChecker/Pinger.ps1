# This script is designed to Ping a list of devices found using the defender KQL scripts in this folder.
# It will feed back a simple table showing which devices are reachable and which arent.
# Tip- it's logical to assess which data you need to scan, if a lot of it is 169.254 or public IPv4's (link local IPv4 addresses) may as well remove them from the data source.

# 1. Load the file
$path = "IPAddresses.xlsx"

if (-not (Test-Path $path)) { 
    Write-Error "File not found at $path. Please check the file path."
    return 
}

$rows = Import-Excel -Path $path
Write-Host "Found $($rows.Count) rows in the Excel file." -ForegroundColor Cyan

# 2. Process
$results = foreach ($row in $rows) {
    # DEBUG: See what PowerShell thinks the columns are named
    # Write-Host "Checking row for device: $($row.DeviceName)" 

    $device = $row.DeviceName
    $rawJson = $row.IPAddresses 

    $bestIp = $null
    $reason = "Unknown"

    if ([string]::IsNullOrWhiteSpace($rawJson)) {
        $reason = "Empty IP Cell"
    } else {
        try {
            # Clean common Excel formatting issues (hidden quotes)
            $cleanJson = $rawJson.Replace('“', '"').Replace('”', '"').Trim()
            $ipObjects = $cleanJson | ConvertFrom-Json
            
            # Filter for IPv4 (dots) and prioritize Private
            $bestIpObj = $ipObjects | Where-Object { $_.IPAddress -like '*.*' } | 
                         Sort-Object { $_.AddressType -eq 'Private' } -Descending | 
                         Select-Object -First 1

            if ($bestIpObj) {
                $bestIp = $bestIpObj.IPAddress
            } else {
                $reason = "No IPv4 in JSON"
            }
        } catch {
            $reason = "JSON Parse Error"
        }
    }

    if ($bestIp) {
        if (Test-Connection $bestIp -Count 1 -Quiet -ErrorAction SilentlyContinue) {
            $reachable = $true
            $reason = "OK"
        } else {
            $reachable = $false
            $reason = "No reply"
        }
    } else {
        $reachable = $false
    }

    [pscustomobject]@{
        DeviceName = $device
        ChosenIP   = $bestIp
        Reachable  = $reachable
        Reason     = $reason
    }
}

# 3. Explicitly output the results
if ($results) {
    $results | Sort-Object Reachable | Format-Table -AutoSize
} else {
    Write-Warning "The results array is empty. Check if your Excel headers match 'DeviceName' and 'IPAddresses'."
}
