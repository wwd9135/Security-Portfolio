<#
.SYNOPSIS
    Intune Proactive Remediation REMEDIATION — Re-link the Tenable Nessus Agent to the cloud.

.DESCRIPTION
    Attempts to link an unlinked Nessus Agent to cloud.tenable.com. Uses a two-pass
    strategy: proxy link first (for devices behind a corporate proxy or iBoss), then
    a direct link attempt (for devices on DirectAccess or where proxy is transparent).

    The OS ProductType is used to assign the agent to the correct scanner group:
      ProductType 1 (Workstation) → Windows_Agent_Enduser
      Other (Server/DC)           → Windows_Agent_Server

    Proxy selection: if iBoss is installed the cloud/external proxy is used;
    otherwise the internal proxy is used. Replace all proxy.contoso.com placeholders
    with your actual proxy hostnames before deploying.

    Paired with Test-TenableAgentLink.ps1.

.NOTES
    Sensitive placeholders:
      <NESSUS-LINKING-KEY>       — replace with your Tenable.io activation key
      proxy.contoso.com          — external/cloud proxy (behind iBoss or cloud filter)
      proxy-internal.contoso.com — internal proxy (direct connection)
      DC=contoso,DC=com          — your AD domain (used for proxy routing decision)
#>

$ExePath = "$env:ProgramFiles\Tenable\Nessus Agent\nessuscli.exe"

if (-not (Test-Path $ExePath)) {
    Write-Output "FAIL: nessuscli.exe not found at $ExePath"
    exit 1
}

$ibossInstalled = Get-Service -Name 'ibsa' -ErrorAction SilentlyContinue
Write-Output "INFO: iBoss installed: $($null -ne $ibossInstalled)"

# Determine domain membership and select proxy accordingly
$Domain = $null
try { $Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain() } catch {}
Write-Output "INFO: Device domain: $($Domain.Name)"

if ($ibossInstalled) {
    $Proxy     = 'proxy.contoso.com'
    $ProxyPort = '8082'
}
else {
    $Proxy     = 'proxy-internal.contoso.com'
    $ProxyPort = '8080'
}
Write-Output "INFO: Resolved proxy: ${Proxy}:${ProxyPort}"

$osInfo      = (Get-CimInstance -Class Win32_OperatingSystem).ProductType
$TenableGroup = if ($osInfo -eq 1) { 'Windows_Agent_Enduser' } else { 'Windows_Agent_Server' }
Write-Output "INFO: OS ProductType $osInfo — scanner group: $TenableGroup"

$NessusKey   = '<NESSUS-LINKING-KEY>'

$AgentStatus = & $ExePath agent status
Write-Output "INFO: Agent status before remediation: $($AgentStatus -join ' ')"

# Pass 1: link via corporate proxy
if ($AgentStatus -match 'not linked') {
    Write-Output "INFO: Attempting proxy link ($Proxy : $ProxyPort)..."
    & $ExePath agent link --cloud --key=$NessusKey --proxy-host=$Proxy --proxy-port=$ProxyPort --groups=$TenableGroup
    Start-Sleep -Seconds 30
    $AgentStatus = & $ExePath agent status
    Write-Output "INFO: Status after proxy link: $($AgentStatus -join ' ')"
}

# Pass 2: direct link (DirectAccess or transparent proxy)
if ($AgentStatus -match 'not linked') {
    Write-Output "INFO: Proxy link failed — attempting direct link..."
    & $ExePath agent link --cloud --key=$NessusKey --groups=$TenableGroup
    & $ExePath fix --secure --set proxy=$Proxy
    & $ExePath fix --secure --set proxy_port=$ProxyPort
    & $ExePath fix --secure --set ignore_proxy=yes
    Start-Sleep -Seconds 30
    $AgentStatus = & $ExePath agent status
    Write-Output "INFO: Status after direct link: $($AgentStatus -join ' ')"
}

if ($AgentStatus -match 'not linked') {
    Write-Output "FAIL: Agent still not linked after proxy and direct link attempts — manual investigation required"
    exit 1
}

Write-Output "SUCCESS: Tenable Agent linked to cloud.tenable.com"
exit 0
