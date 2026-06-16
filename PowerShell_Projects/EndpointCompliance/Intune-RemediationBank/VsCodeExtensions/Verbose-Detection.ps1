# Detection - VS Code AllowedExtensions policy compliance
# Write-Host output is captured by Intune Management Extension (IME) automatically

# --- Config ---
$regpath              = "HKLM:\SOFTWARE\Policies\Microsoft\VSCode"
$name                 = "AllowedExtensions"
$minimumVersion       = [Version]"1.96.0"
$expectedPolicyValue  = '{"*": true, "anthropic": false, "openai": false}'

Write-Host "===== VS Code Policy Detection ====="
Write-Host "Running as: $(whoami)"
Write-Host "Expected policy value: $expectedPolicyValue"
Write-Host ""

# --- Locate VS Code  ---
$vsCodePath  = $null
$installType = $null

$machinePath = "$env:ProgramFiles\Microsoft VS Code\Code.exe"
Write-Host "[CHECK] Machine-wide install: $machinePath"
if (Test-Path $machinePath) {
    $vsCodePath  = $machinePath
    $installType = "Machine"
    Write-Host "  -> FOUND"
} else {
    Write-Host "  -> not present"
}

if (-not $vsCodePath) {
    Write-Host "[CHECK] Scanning user profiles for per-user installs..."
    Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $userCodePath = Join-Path $_.FullName "AppData\Local\Programs\Microsoft VS Code\Code.exe"
        Write-Host "  Checking: $userCodePath"
        if (Test-Path $userCodePath) {
            $vsCodePath  = $userCodePath
            $installType = "User ($($_.Name))"
            Write-Host "  -> FOUND in $($_.Name) profile"
        }
    }
}

if (-not $vsCodePath) {
    Write-Host ""
    Write-Host "[RESULT] VS Code not installed - no action needed"
    Write-Host "[EXIT] 0 (COMPLIANT)"
    exit 0
}

Write-Host ""
Write-Host "[INFO] VS Code path: $vsCodePath"
Write-Host "[INFO] Install type: $installType"

# --- Validate version ---
Write-Host ""
Write-Host "[CHECK] Reading VS Code version..."
try {
    $versionString    = (Get-Item $vsCodePath).VersionInfo.ProductVersion
    $installedVersion = [Version]$versionString
    Write-Host "  -> Version detected: v$installedVersion"
} catch {
    Write-Host "  -> ERROR reading version: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "[RESULT] Version could not be determined - skipping"
    Write-Host "[EXIT] 0 (COMPLIANT - skipped)"
    exit 0
}

Write-Host "[CHECK] Comparing against minimum v$minimumVersion..."
if ($installedVersion -lt $minimumVersion) {
    Write-Host "  -> v$installedVersion is BELOW minimum v$minimumVersion"
    Write-Host "  -> Feature not supported in this version"
    Write-Host ""
    Write-Host "[RESULT] VS Code version pre-dates AllowedExtensions feature"
    Write-Host "[EXIT] 0 (COMPLIANT - feature unavailable)"
    exit 0
}
Write-Host "  -> v$installedVersion meets minimum requirement"

# --- Read current policy value ---
Write-Host ""
Write-Host "[CHECK] Reading current policy from registry..."
Write-Host "  Path: $regpath"
Write-Host "  Value: $name"

$currentValue = $null
try {
    $currentValue = (Get-ItemProperty -Path $regpath -Name $name -ErrorAction Stop).$name
    Write-Host "  -> Current value found:"
    Write-Host "     $currentValue"
} catch {
    Write-Host "  -> Registry key/value NOT present"
}

# --- Compare current vs expected ---
Write-Host ""
Write-Host "[CHECK] Comparing current vs expected policy..."

if ($null -eq $currentValue) {
    Write-Host "  -> Policy missing entirely"
    Write-Host ""
    Write-Host "[RESULT] Policy not set - remediation required"
    Write-Host "[EXIT] 1 (NON-COMPLIANT)"
    exit 1
}

if ($currentValue -ceq $expectedPolicyValue) {
    Write-Host "  -> Values MATCH exactly"
    Write-Host ""
    Write-Host "[RESULT] Policy matches expected value"
    Write-Host "[EXIT] 0 (COMPLIANT)"
    exit 0
} else {
    Write-Host "  -> Values DIFFER (drift detected)"
    Write-Host "     Current : $currentValue"
    Write-Host "     Expected: $expectedPolicyValue"
    Write-Host ""
    Write-Host "[RESULT] Policy value drift - remediation required"
    Write-Host "[EXIT] 1 (NON-COMPLIANT)"
    exit 1
}