<#
.SYNOPSIS
    Searches Intune for policies, scripts, and remediations that contain specified keyword terms.

.DESCRIPTION
    Connects to Microsoft Graph (v1.0 and beta endpoints) and searches across four
    Intune workloads for a configurable set of keywords:
      - PowerShell scripts (deviceManagementScripts)
      - Proactive Remediations / Device Health Scripts (deviceHealthScripts)
      - Custom OMA-URI profiles (windows10CustomConfiguration)
      - Settings Catalog policies (configurationPolicies)

    Results are displayed as a formatted table and written to a JSON file for sharing.

    Requires the Microsoft.Graph and Microsoft.Graph.Beta modules.

.PARAMETER Terms
    Array of keyword strings to search for across policy content.
    Defaults to a set relevant to certificate and cryptography hardening.

.PARAMETER OutputPath
    Path for the JSON findings file.
    Defaults to 'Intune_PolicyFindings.json' in the current directory.

.EXAMPLE
    .\Find-IntunePolicies.ps1

.EXAMPLE
    .\Find-IntunePolicies.ps1 -Terms "EnableCertPaddingCheck","TLS 1.2" -OutputPath "C:\audit\findings.json"

.NOTES
    Requires: Microsoft.Graph, Microsoft.Graph.Beta modules
    Graph scopes: DeviceManagementConfiguration.Read.All, DeviceManagementScripts.Read.All
    Replace <TENANT-ID> and <CLIENT-ID> with your Entra ID app registration values.
#>

[CmdletBinding()]
param(
    [string[]]$Terms = @("Padding","Enable","Cryptography","Wintrust","Config"),

    [string]$OutputPath = "Intune_PolicyFindings.json"
)

#region Helpers

function Test-StringMatch {
    param([string]$Text, [string[]]$Patterns)
    foreach ($p in $Patterns) {
        if ($Text -match [regex]::Escape($p)) { return $true }
    }
    return $false
}

#endregion

#region Connect

Set-MgGraphOption -DisableLoginByWAM $true
Connect-MgGraph `
    -ClientId  "<CLIENT-ID>" `
    -TenantId  "<TENANT-ID>" `
    -Scopes    "DeviceManagementConfiguration.Read.All","DeviceManagementScripts.Read.All"

#endregion

$findings = [System.Collections.Generic.List[object]]::new()

#region 1. PowerShell Scripts (Devices > Scripts)

$scripts = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts"
foreach ($s in $scripts.value) {
    $detail = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/$($s.id)"
    if ($detail.scriptContent) {
        $plain = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($detail.scriptContent))
        if (Test-StringMatch -Text $plain -Patterns $Terms) {
            $assign = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/$($s.id)/assignments"
            $findings.Add([pscustomobject]@{
                Type         = 'Script'
                Id           = $s.id
                Name         = $s.displayName
                LastModified = $s.lastModifiedDateTime
                MatchHint    = 'deviceManagementScripts.scriptContent'
                Assignments  = ($assign.value | Select-Object -ExpandProperty target | ConvertTo-Json -Compress)
            })
        }
    }
}

#endregion

#region 2. Proactive Remediations / Device Health Scripts

$pr = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts"
foreach ($h in $pr.value) {
    $det = ''
    $rem = ''
    if ($h.detectionScriptContent)   { $det = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($h.detectionScriptContent)) }
    if ($h.remediationScriptContent) { $rem = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($h.remediationScriptContent)) }

    if ((Test-StringMatch $det $Terms) -or (Test-StringMatch $rem $Terms)) {
        $assign = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts/$($h.id)/assignments"
        $findings.Add([pscustomobject]@{
            Type         = 'ProactiveRemediation'
            Id           = $h.id
            Name         = $h.displayName
            LastModified = $h.lastModifiedDateTime
            MatchHint    = if (Test-StringMatch $det $Terms) { 'detectionScriptContent' } else { 'remediationScriptContent' }
            Assignments  = ($assign.value | Select-Object -ExpandProperty target | ConvertTo-Json -Compress)
        })
    }
}

#endregion

#region 3. Custom OMA-URI Profiles

$devConfs = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations`?`$filter=isof('microsoft.graph.windows10CustomConfiguration')"
foreach ($c in $devConfs.value) {
    $cFull = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations/$($c.id)"
    $oma = $cFull.omaSettings
    if ($oma) {
        $match = $false
        foreach ($s in $oma) {
            $joined = "$($s.omaUri) $($s.value) $($s.displayName)"
            if (Test-StringMatch $joined $Terms) { $match = $true; break }
        }
        if ($match) {
            $assign = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations/$($c.id)/assignments"
            $findings.Add([pscustomobject]@{
                Type         = 'CustomOMA'
                Id           = $c.id
                Name         = $c.displayName
                LastModified = $c.lastModifiedDateTime
                MatchHint    = 'omaSettings (uri/value/displayName)'
                Assignments  = ($assign.value | ConvertTo-Json -Compress)
            })
        }
    }
}

#endregion

#region 4. Settings Catalog Policies

$scp = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies"
foreach ($p in $scp.value) {
    $settings = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$($p.id)/settings"
    $json = $settings | ConvertTo-Json -Depth 8
    if (Test-StringMatch $json $Terms) {
        $assign = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$($p.id)/assignments"
        $findings.Add([pscustomobject]@{
            Type         = 'SettingsCatalog'
            Id           = $p.id
            Name         = $p.name
            LastModified = $p.lastModifiedDateTime
            MatchHint    = 'configurationPolicies.settings payload'
            Assignments  = ($assign.value | ConvertTo-Json -Compress)
        })
    }
}

#endregion

#region Output

$findings | Sort-Object Type, Name | Format-Table Type, Name, Id, LastModified, MatchHint -AutoSize
$findings | ConvertTo-Json -Depth 6 | Out-File $OutputPath -Encoding UTF8
Write-Host "Saved $($findings.Count) finding(s) to $OutputPath"

#endregion
