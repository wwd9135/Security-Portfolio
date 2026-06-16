<#
.SYNOPSIS
    Intune Proactive Remediation DETECTION — Tenable Nessus Agent cloud link status.

.DESCRIPTION
    Calls nessuscli.exe agent status and checks whether the agent is linked
    to cloud.tenable.com. Exits 1 if not linked, triggering the remediation
    script to re-link the agent.

    Exit codes:
      0 = Agent linked to cloud.tenable.com — do NOT remediate
      1 = Agent not linked or nessuscli.exe not found — run Invoke-TenableAgentLink.ps1
#>

$ExePath = "$env:ProgramFiles\Tenable\Nessus Agent\nessuscli.exe"

if (-not (Test-Path $ExePath)) {
    Write-Output "FAIL: nessuscli.exe not found — agent may not be installed"
    exit 1
}

$AgentStatus = & $ExePath agent status

if ($AgentStatus -match 'cloud.tenable.com:443') {
    Write-Output "PASS: Tenable agent linked to cloud.tenable.com"
    exit 0
}

Write-Output "FAIL: Tenable agent not linked"
exit 1
