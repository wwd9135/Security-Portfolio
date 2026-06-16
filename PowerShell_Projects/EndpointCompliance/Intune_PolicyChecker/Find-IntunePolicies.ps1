# Configure search terms you care about, these are an example I built this script for.
$terms = @("Padding","Enable","Cryptography","Wintrust","Config")

# Helper: simple matcher for multiple terms
function Matches-Any {
    param($text, [string[]]$patterns)
    foreach ($p in $patterns) { if ($text -match [regex]::Escape($p)) { return $true } }
    return $false
}

# 1) Install / update the SDKs
Install-Module Microsoft.Graph -Scope CurrentUser -AllowClobber -Force
Install-Module Microsoft.Graph.Beta -Scope CurrentUser -AllowClobber -Force   # <- new in v2 model

# 2) Disable WAM and connect with your custom app registration
Set-MgGraphOption -DisableLoginByWAM $true
Connect-MgGraph -ClientId "<Instert clientID>" -TenantId "<Insert tenantID>" `
  -Scopes "DeviceManagementConfiguration.Read.All","DeviceManagementScripts.Read.All"

# 3) Use Mg (v1.0) and MgBeta (beta) cmdlets side-by-side in the same script
# Example (names will vary by workload):
# $scripts = Get-MgBetaDeviceManagementDeviceHealthScript

$findings = [System.Collections.Generic.List[object]]::new()

# 1) Intune PowerShell Scripts (Devices > Scripts)
# API: GET /deviceManagement/deviceManagementScripts
# Docs: https://learn.microsoft.com/graph/api/intune-shared-devicemanagementscript-list
$scripts = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts"
foreach ($s in $scripts.value) {
    # Content is base64 in scriptContent (may require a GET per-id, depending on tenant)
    $detail = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/$($s.id)"
    if ($detail.scriptContent) {
        $plain = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($detail.scriptContent))
        if (Matches-Any -text $plain -patterns $terms) {
            # get assignments for context
            $assign = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/$($s.id)/assignments"
            $findings.Add([pscustomobject]@{
                Type        = 'Script'
                Id          = $s.id
                Name        = $s.displayName
                LastModified= $s.lastModifiedDateTime
                MatchHint   = 'deviceManagementScripts.scriptContent'
                Assignments = ($assign.value | Select-Object -ExpandProperty target | ConvertTo-Json -Compress)
            })
        }
    }
}
# (Docs for deviceManagementScripts: beta list + resource type)  # [1](https://learn.microsoft.com/en-us/graph/api/intune-shared-devicemanagementscript-list?view=graph-rest-beta)[2](https://learn.microsoft.com/en-us/graph/api/resources/intune-shared-devicemanagementscript?view=graph-rest-beta)

# 2) Proactive Remediations (Device Health Scripts)
# API: GET /deviceManagement/deviceHealthScripts
# Docs: https://learn.microsoft.com/graph/api/intune-devices-devicehealthscript-list
$pr = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts"
foreach ($h in $pr.value) {
    $det = ''
    $rem = ''
    if ($h.detectionScriptContent) { $det = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($h.detectionScriptContent)) }
    if ($h.remediationScriptContent){ $rem = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($h.remediationScriptContent)) }

    if (Matches-Any $det $terms -or Matches-Any $rem $terms) {
        $assign = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts/$($h.id)/assignments"
        $findings.Add([pscustomobject]@{
            Type        = 'ProactiveRemediation'
            Id          = $h.id
            Name        = $h.displayName
            LastModified= $h.lastModifiedDateTime
            MatchHint   = if (Matches-Any $det $terms) { 'detectionScriptContent' } else { 'remediationScriptContent' }
            Assignments = ($assign.value | Select-Object -ExpandProperty target | ConvertTo-Json -Compress)
        })
    }
}
# (Docs for deviceHealthScripts listing + relationships)  # [4](https://learn.microsoft.com/en-us/graph/api/intune-devices-devicehealthscript-list?view=graph-rest-beta)[5](https://learn.microsoft.com/en-us/graph/api/resources/intune-devices-devicehealthscript?view=graph-rest-beta)

# 3) Custom OMA-URI Profiles (windows10CustomConfiguration)
# API: GET /deviceManagement/deviceConfigurations?isof('microsoft.graph.windows10CustomConfiguration')
# Docs: https://learn.microsoft.com/graph/api/intune-deviceconfig-windows10customconfiguration-create
$devConfs = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations`?$filter=isof('microsoft.graph.windows10CustomConfiguration')"
foreach ($c in $devConfs.value) {
    # Each has additionalProperties.omaSettings in SDK; via REST, do a GET per-id for full body
    $cFull = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations/$($c.id)"
    $oma = $cFull.omaSettings
    if ($oma) {
        # Search both OMA-URI and value fields for hints (rare for this reg key, but thorough)
        $match = $false
        foreach ($s in $oma) {
            $joined = ($s.omaUri + ' ' + $s.value + ' ' + $s.displayName)
            if (Matches-Any $joined $terms) { $match = $true; break }
        }
        if ($match) {
            $assign = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations/$($c.id)/assignments"
            $findings.Add([pscustomobject]@{
                Type        = 'CustomOMA'
                Id          = $c.id
                Name        = $c.displayName
                LastModified= $c.lastModifiedDateTime
                MatchHint   = 'omaSettings (uri/value/displayName)'
                Assignments = ($assign.value | ConvertTo-Json -Compress)
            })
        }
    }
}
# (Custom profiles & OMA settings in Intune/Graph)  # [7](https://learn.microsoft.com/en-us/graph/api/intune-deviceconfig-windows10customconfiguration-create?view=graph-rest-1.0)

# 4) Settings Catalog Policies (configurationPolicies)
# API: GET /deviceManagement/configurationPolicies ; then /{id}/settings
# Docs: https://learn.microsoft.com/graph/api/intune-deviceconfigv2-devicemanagementconfigurationpolicy-list
$scp = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies"
foreach ($p in $scp.value) {
    $settings = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$($p.id)/settings"
    $json = $settings | ConvertTo-Json -Depth 8
    if (Matches-Any $json $terms) {
        $assign = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$($p.id)/assignments"
        $findings.Add([pscustomobject]@{
            Type        = 'SettingsCatalog'
            Id          = $p.id
            Name        = $p.name
            LastModified= $p.lastModifiedDateTime
            MatchHint   = 'configurationPolicies.settings payload'
            Assignments = ($assign.value | ConvertTo-Json -Compress)
        })
    }
}
# (Settings Catalog via configurationPolicies & settings)  # [8](https://learn.microsoft.com/en-us/graph/api/intune-deviceconfigv2-devicemanagementconfigurationpolicy-list?view=graph-rest-beta)[9](https://powers-hell.com/2021/03/08/working-with-intune-settings-catalog-using-powershell-and-graph/)

# Output: nice table + JSON file you can share
$findings | Sort-Object Type, Name | Format-Table Type, Name, Id, LastModified, MatchHint -Auto
$findings | ConvertTo-Json -Depth 6 | Out-File ".\Intune_EnableCertPaddingCheck_Findings.json" -Encoding UTF8
Write-Host "`nSaved details to Intune_EnableCertPaddingCheck_Findings.json"
