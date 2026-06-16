<#
.SYNOPSIS
    Generate a compliance and configuration report for Intune-managed devices.

.DESCRIPTION
    Queries Microsoft Graph for each device name supplied in a hostname CSV file,
    retrieves compliance policy state and configuration policy state per device,
    and exports a summary report in CSV, JSON, or HTML format.

    Authentication: interactive browser sign-in via Connect-MgGraph.
    Required scopes:
      DeviceManagementManagedDevices.Read.All
      DeviceManagementConfiguration.Read.All
      Directory.Read.All

    Devices not found in Intune are silently skipped.

.PARAMETER HostnameFile
    Path to a text file containing one device name per line.
    Blank lines are ignored; names are trimmed and uppercased.

.PARAMETER OutputPath
    Destination file path for the report.
    Default: ComplianceReport_<timestamp>.csv in the current directory.

.PARAMETER Format
    Output format: CSV (default), JSON, or HTML.

.EXAMPLE
    .\Get-IntuneComplianceReport.ps1 -HostnameFile .\devices.txt
    Produces a CSV report for all named devices.

.EXAMPLE
    .\Get-IntuneComplianceReport.ps1 -HostnameFile .\devices.txt -Format HTML -OutputPath .\report.html
    Produces a styled HTML report.

.NOTES
    Requires: Microsoft.Graph PowerShell SDK
    Install : Install-Module Microsoft.Graph -Scope CurrentUser
#>

function Get-IntuneComplianceReport {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$HostnameFile,

        [string]$OutputPath = "ComplianceReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv",

        [ValidateSet('CSV', 'JSON', 'HTML')]
        [string]$Format = 'CSV'
    )

    $ErrorActionPreference = 'SilentlyContinue'
    $ComplianceResults     = @()

    # --- LOAD HOSTNAMES ---
    $Hostnames = Get-Content -Path $HostnameFile |
        Where-Object { $_ -match '\S' } |
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

        Import-Module Microsoft.Graph.Authentication  -ErrorAction SilentlyContinue
        Import-Module Microsoft.Graph.DeviceManagement -ErrorAction SilentlyContinue

        $Scopes = @(
            'DeviceManagementManagedDevices.Read.All',
            'DeviceManagementConfiguration.Read.All',
            'Directory.Read.All'
        )

        Connect-MgGraph -Scopes $Scopes -NoWelcome -ErrorAction Stop
    }
    catch {
        Write-Warning 'Failed to connect to Microsoft Graph. Exiting.'
        return
    }

    # --- QUERY EACH DEVICE ---
    foreach ($Hostname in $Hostnames) {

        # OData server-side filter avoids pulling all managed devices
        $Device = Get-MgDeviceManagementManagedDevice `
            -Filter "deviceName eq '$Hostname'" `
            -ErrorAction SilentlyContinue |
            Select-Object -First 1

        if (-not $Device) { continue }

        try {
            $ComplianceStatus    = Get-MgDeviceManagementManagedDeviceDeviceCompliancePolicyState `
                -ManagedDeviceId $Device.Id -ErrorAction SilentlyContinue
            $ConfigurationStatus = Get-MgDeviceManagementManagedDeviceDeviceConfigurationState `
                -ManagedDeviceId $Device.Id -ErrorAction SilentlyContinue
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
        Write-Warning 'No matching devices found in Intune.'
    }
    else {
        try {
            switch ($Format) {
                'CSV'  {
                    $ComplianceResults | Export-Csv -Path $OutputPath -NoTypeInformation -Force
                }
                'JSON' {
                    $ComplianceResults | ConvertTo-Json -Depth 4 |
                        Out-File -FilePath $OutputPath -Encoding UTF8 -Force
                }
                'HTML' {
                    $style = '<style>table{border-collapse:collapse;width:100%}th,td{border:1px solid #ddd;padding:8px}th{background:#f2f2f2}</style>'
                    $ComplianceResults | ConvertTo-Html -Title 'Intune Compliance Report' -Head $style |
                        Out-File -FilePath $OutputPath -Encoding UTF8 -Force
                }
            }
            Write-Host "Report saved: $OutputPath"
        }
        catch {
            Write-Warning 'Failed to write output file.'
        }
    }

    try { Disconnect-MgGraph -ErrorAction SilentlyContinue } catch {}

    return $ComplianceResults
}
