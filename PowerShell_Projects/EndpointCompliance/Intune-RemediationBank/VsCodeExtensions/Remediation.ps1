# Remediation - Configure VS Code AllowedExtensions and UpdateMode policies
# Write-Host output is captured by Intune Management Extension (IME) automatically
# On endpoint: C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\AgentExecutor.log

# --- Config ---
$regpath                = "HKLM:\SOFTWARE\Policies\Microsoft\VSCode"
$allowedExtensionsName  = "AllowedExtensions"
$allowedExtensionsValue = '{"*": true, "anthropic": false, "openai": false}'
$updateModeName         = "UpdateMode"
$updateModeValue        = "default"

Write-Host "===== VS Code Policy Remediation ====="
Write-Host "Running as: $(whoami)"
Write-Host "Target path: $regpath"
Write-Host ""

try {
    # --- Ensure registry path exists ---
    Write-Host "[STEP 1] Checking registry path..."
    if (-not (Test-Path $regpath)) {
        Write-Host "  -> Path does not exist, creating: $regpath"
        New-Item -Path $regpath -Force | Out-Null
        Write-Host "  -> Path created successfully"
    } else {
        Write-Host "  -> Path already exists"
    }

    # --- Set AllowedExtensions ---
    Write-Host ""
    Write-Host "[STEP 2] Setting AllowedExtensions policy..."
    Write-Host "  Name:  $allowedExtensionsName"
    Write-Host "  Value: $allowedExtensionsValue"
    Set-ItemProperty -Path $regpath -Name $allowedExtensionsName -Value $allowedExtensionsValue -Type String -Force
    $writtenAllowed = (Get-ItemProperty -Path $regpath -Name $allowedExtensionsName -ErrorAction Stop).$allowedExtensionsName
    if ($writtenAllowed -ceq $allowedExtensionsValue) {
        Write-Host "  -> Write verified successfully"
    } else {
        Write-Host "  -> WARNING: Written value does not match expected"
        Write-Host "     Written : $writtenAllowed"
        Write-Host "     Expected: $allowedExtensionsValue"
        throw "AllowedExtensions write verification failed"
    }

    # --- Set UpdateMode ---
    Write-Host ""
    Write-Host "[STEP 3] Setting UpdateMode policy..."
    Write-Host "  Name:  $updateModeName"
    Write-Host "  Value: $updateModeValue"
    Set-ItemProperty -Path $regpath -Name $updateModeName -Value $updateModeValue -Type String -Force
    $writtenMode = (Get-ItemProperty -Path $regpath -Name $updateModeName -ErrorAction Stop).$updateModeName
    if ($writtenMode -ceq $updateModeValue) {
        Write-Host "  -> Write verified successfully"
    } else {
        Write-Host "  -> WARNING: Written value does not match expected"
        Write-Host "     Written : $writtenMode"
        Write-Host "     Expected: $updateModeValue"
        throw "UpdateMode write verification failed"
    }

    # --- Done ---
    Write-Host ""
    Write-Host "[RESULT] All VS Code policies configured successfully"
    Write-Host "[EXIT] 0 (SUCCESS)"
    exit 0
}
catch {
    Write-Host ""
    Write-Host "[ERROR] Remediation failed: $($_.Exception.Message)"
    Write-Host "[ERROR] At line: $($_.InvocationInfo.ScriptLineNumber)"
    Write-Host "[EXIT] 1 (FAILURE)"
    exit 1
}