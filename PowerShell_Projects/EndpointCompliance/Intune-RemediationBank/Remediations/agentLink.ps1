$ExePath = "${env:ProgramFiles}\Tenable\Nessus Agent\nessuscli.exe"

if (-not (Test-Path $ExePath)) {
    Write-Output "FAIL: nessuscli.exe not found at expected path - $ExePath. Agent may not be installed"
    exit 1
}

$ibossInstalled = Get-Service -Name 'ibsa' -ErrorAction SilentlyContinue
Write-Output "INFO: iboss installed: $($null -ne $ibossInstalled)"

$Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
Write-Output "INFO: Device domain: $($Domain.Name)"

if ($Domain.Name -eq 'mgz.metoffice.gov.uk') {
    if ($ibossInstalled) {
        $Proxy = 'webproxy-cloud.mgz.metoffice.gov.uk'
        $ProxyPort = '8082'
    } else {
        $Proxy = 'webproxy-internal.mgz.metoffice.gov.uk'
        $ProxyPort = '8080'
    }
} else {
    if ($ibossInstalled) {
        $Proxy = 'webproxy-cloud.metoffice.gov.uk'
        $ProxyPort = '8082'
    } else {
        $Proxy = 'webproxy-internal.metoffice.gov.uk'
        $ProxyPort = '8080'
    }
}
Write-Output "INFO: Resolved proxy: $Proxy : $ProxyPort"

$osInfo = (Get-CimInstance -Class Win32_OperatingSystem).ProductType
if ($osInfo -eq 1) {
    $TenableGroup = 'Windows_Agent_Enduser'
} else {
    $TenableGroup = 'Windows_Agent_Server'
}
Write-Output "INFO: OS ProductType: $osInfo - assigned group: $TenableGroup"

$NessusKey = 'eb18d8d38379ee51063daeaff6306f18e3a9e9318365845e6b92310c9544daca'

$AgentStatus = & $ExePath agent status
Write-Output "INFO: Agent status before remediation: $($AgentStatus -join ' ')"

if ($AgentStatus -match "not linked") {
    Write-Output "INFO: Agent not linked - attempting link via proxy ($Proxy : $ProxyPort)..."
    & $ExePath agent link --cloud --key=$NessusKey --proxy-host=$Proxy --proxy-port=$ProxyPort --groups=$TenableGroup
}
Start-Sleep -Seconds 30  # <-- give the agent time to establish the link

$AgentStatus = & $ExePath agent status
Write-Output "INFO: Agent status after proxy link attempt: $($AgentStatus -join ' ')"

if ($AgentStatus -match "not linked") {
    Write-Output "INFO: Proxy link failed - attempting direct link (device may be on DirectAccess)..."
    & $ExePath agent link --cloud --key=$NessusKey --groups=$TenableGroup
    & $ExePath fix --secure --set proxy=$Proxy
    & $ExePath fix --secure --set proxy_port=$ProxyPort
    & $ExePath fix --secure --set ignore_proxy=yes
    Write-Output "INFO: Direct link attempted - proxy settings stored with ignore_proxy=yes"
}
Start-Sleep -Seconds 30  # <-- give the agent time to establish the link

$AgentStatus = & $ExePath agent status
Write-Output "INFO: Agent status after all link attempts: $($AgentStatus -join ' ')"

if ($AgentStatus -match "not linked") {
    Write-Output "FAIL: Agent still not linked after proxy and direct link attempts - manual investigation required"
    exit 1
}

Write-Output "SUCCESS: Tenable Agent is linked to cloud.tenable.com"
exit 0#