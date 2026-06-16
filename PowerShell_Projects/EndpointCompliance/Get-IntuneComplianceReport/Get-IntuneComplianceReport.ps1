# Get-AdvancedComplianceReport.ps1

function Get-AdvancedComplianceReport {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$HostnameFile,

        [string]$OutputPath = "ComplianceReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv",

        [ValidateSet("CSV", "JSON", "HTML")]
        [string]$Format = "CSV"
    )

    $ErrorActionPreference = "SilentlyContinue"
    $ComplianceResults = @()

    # --- LOAD HOSTNAMES ---
    $Hostnames = Get-Content -Path $HostnameFile |
        Where-Object { $_ -match '\S' } |   # Drop blank lines
        ForEach-Object { $_.Trim().ToUpper() }

    if ($Hostnames.Count -eq 0) {
        Write-Warning "No hostnames found in '$HostnameFile'. Exiting."
        return
    }

    # --- MODULE & GRAPH CONNECTION ---
    try {
        if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
            Install-Module Microsoft.Graph -Scope CurrentUser -Force -ErrorAction SilentlyContinue
        }

        Import-Module Microsoft.Graph.Authentication -ErrorAction SilentlyContinue
        Import-Module Microsoft.Graph.DeviceManagement -ErrorAction SilentlyContinue

        $Scopes = @(
            "DeviceManagementManagedDevices.Read.All",
            "DeviceManagementConfiguration.Read.All",
            "Directory.Read.All"
        )

        Connect-MgGraph -Scopes $Scopes -NoWelcome -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to connect to Microsoft Graph. Exiting."
        return
    }

    # --- QUERY EACH HOSTNAME INDIVIDUALLY ---
    foreach ($Hostname in $Hostnames) {

        # Use OData $filter to query server-side — avoids pulling all devices
        $Device = Get-MgDeviceManagementManagedDevice `
            -Filter "deviceName eq '$Hostname'" `
            -ErrorAction SilentlyContinue |
            Select-Object -First 1   # Guard against duplicate device names

        # Not found in Intune — skip silently
        if (-not $Device) { continue }

        # --- COMPLIANCE & CONFIGURATION STATE ---
        try {
            $ComplianceStatus = Get-MgDeviceManagementManagedDeviceDeviceCompliancePolicyState `
                -ManagedDeviceId $Device.Id `
                -ErrorAction SilentlyContinue

            $ConfigurationStatus = Get-MgDeviceManagementManagedDeviceDeviceConfigurationState `
                -ManagedDeviceId $Device.Id `
                -ErrorAction SilentlyContinue
        }
        catch {
            $ComplianceStatus    = @()
            $ConfigurationStatus = @()
        }

        $ComplianceResults += [PSCustomObject]@{
            DeviceName                 = $Device.DeviceName
            DeviceId                   = $Device.Id
            UserPrincipalName          = $Device.UserPrincipalName
            Platform                   = $Device.OperatingSystem
            OSVersion                  = $Device.OsVersion
            ComplianceState            = $Device.ComplianceState
            LastSyncDateTime           = $Device.LastSyncDateTime
            EnrollmentDateTime         = $Device.EnrolledDateTime
            ManagementAgent            = $Device.ManagementAgent
            DeviceType                 = $Device.DeviceType
            Manufacturer               = $Device.Manufacturer
            Model                      = $Device.Model
            SerialNumber               = $Device.SerialNumber
            TotalStorageSpaceInBytes   = $Device.TotalStorageSpaceInBytes
            FreeStorageSpaceInBytes    = $Device.FreeStorageSpaceInBytes
            CompliancePoliciesCount    = ($ComplianceStatus    | Measure-Object).Count
            ConfigurationPoliciesCount = ($ConfigurationStatus | Measure-Object).Count
            IsEncrypted                = $Device.IsEncrypted
            IsSupervised               = $Device.IsSupervised
            ExchangeAccessState        = $Device.ExchangeAccessState
            ExchangeAccessStateReason  = $Device.ExchangeAccessStateReason
        }
    }

    # --- OUTPUT ---
    if ($ComplianceResults.Count -eq 0) {
        Write-Warning "No matching devices found in Intune."
    }
    else {
        try {
            switch ($Format) {
                "CSV" {
                    $ComplianceResults | Export-Csv -Path $OutputPath -NoTypeInformation -Force
                }
                "JSON" {
                    $ComplianceResults | ConvertTo-Json -Depth 4 |
                        Out-File -FilePath $OutputPath -Encoding UTF8 -Force
                }
                "HTML" {
                    $ComplianceResults | ConvertTo-Html -Title "Advanced Compliance Report" `
                        -Head "<style>table{border-collapse:collapse;width:100%}th,td{border:1px solid #ddd;padding:8px}th{background:#f2f2f2}</style>" |
                        Out-File -FilePath $OutputPath -Encoding UTF8 -Force
                }
            }
            Write-Host "Report saved to: $OutputPath"
        }
        catch {
            Write-Warning "Failed to write output file."
        }
    }

    # --- CLEANUP ---
    try { Disconnect-MgGraph -ErrorAction SilentlyContinue } catch {}

    return $ComplianceResults
}
Get-AdvancedComplianceReport -HostnameFile Test.csv -Format CSV -OutputPath "C:\report.csv"
# Example usage:
# Get-AdvancedComplianceReport -HostnameFile "C:\hostnames.txt"
# Get-AdvancedComplianceReport -HostnameFile "C:\hostnames.txt" -Format HTML -OutputPath "C:\report.html"