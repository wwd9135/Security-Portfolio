<#
.SYNOPSIS
    Intune Proactive Remediation REMEDIATION — Configure VS Code machine-wide extension policies.

.DESCRIPTION
    Writes two machine-scoped VS Code policy values to the registry:
      AllowedExtensions — JSON allowlist of permitted publishers/extensions
      UpdateMode        — Set to 'default' (allow automatic updates)

    Policy values are verified after write; exits 1 if verification fails.
    All output is captured by the Intune Management Extension (IME) and visible
    in: C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\AgentExecutor.log

    Paired with Test-VSCodeExtensionPolicy.ps1.

.NOTES
    Modify $allowedExtensionsValue to match your organisation's permitted extension
    policy. The example below allows all extensions except two specific publishers.
    See VS Code machine policy documentation for the full JSON schema.
#>

$regpath                = 'HKLM:\SOFTWARE\Policies\Microsoft\VSCode'
$allowedExtensionsName  = 'AllowedExtensions'
$allowedExtensionsValue = '{"*": true}'   # Allow all by default — customise as required
$updateModeName         = 'UpdateMode'
$updateModeValue        = 'default'

Write-Output "===== VS Code Policy Remediation ====="
Write-Output "Running as: $(whoami)"
Write-Output "Target: $regpath"

try {
    # Ensure registry path exists
    if (-not (Test-Path $regpath)) {
        New-Item -Path $regpath -Force | Out-Null
        Write-Output "[STEP 1] Registry path created"
    }
    else {
        Write-Output "[STEP 1] Registry path already exists"
    }

    # Set AllowedExtensions
    Set-ItemProperty -Path $regpath -Name $allowedExtensionsName -Value $allowedExtensionsValue -Type String -Force
    $writtenAllowed = (Get-ItemProperty -Path $regpath -Name $allowedExtensionsName -ErrorAction Stop).$allowedExtensionsName
    if ($writtenAllowed -cne $allowedExtensionsValue) {
        throw "AllowedExtensions write verification failed (written: $writtenAllowed)"
    }
    Write-Output "[STEP 2] AllowedExtensions set and verified"

    # Set UpdateMode
    Set-ItemProperty -Path $regpath -Name $updateModeName -Value $updateModeValue -Type String -Force
    $writtenMode = (Get-ItemProperty -Path $regpath -Name $updateModeName -ErrorAction Stop).$updateModeName
    if ($writtenMode -cne $updateModeValue) {
        throw "UpdateMode write verification failed (written: $writtenMode)"
    }
    Write-Output "[STEP 3] UpdateMode set and verified"

    Write-Output "[RESULT] All VS Code policies configured successfully"
    exit 0
}
catch {
    Write-Output "[ERROR] Remediation failed: $($_.Exception.Message)"
    exit 1
}
