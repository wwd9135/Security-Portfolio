<#
.SYNOPSIS
    Intune Proactive Remediation DETECTION — VS Code extension allowlist policy check.

.DESCRIPTION
    Checks whether VS Code is installed and meets minimum version (v1.96), then
    verifies that the AllowedExtensions machine-wide policy key exists at
    HKLM:\SOFTWARE\Policies\Microsoft\VSCode.

    VS Code must be at least v1.96 to support machine-scoped extension policies.
    If VS Code is not installed or is below the minimum version, exits 0 (no action
    needed — nothing to enforce policy against).

    Exit codes:
      0 = VS Code absent, below minimum version, or policy already present
      1 = VS Code installed and meets minimum version but policy is missing
#>

$regpath        = 'HKLM:\SOFTWARE\Policies\Microsoft\VSCode'
$name           = 'AllowedExtensions'
$minimumVersion = [Version]'1.96.0'

$vsCodePath  = $null
$installType = $null

# Check machine-wide installation
$machinePath = "$env:ProgramFiles\Microsoft VS Code\Code.exe"
if (Test-Path $machinePath) {
    $vsCodePath  = $machinePath
    $installType = 'Machine'
}

# Check per-user installations across all profiles
if (-not $vsCodePath) {
    Get-ChildItem 'C:\Users' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $userCodePath = Join-Path $_.FullName 'AppData\Local\Programs\Microsoft VS Code\Code.exe'
        if (Test-Path $userCodePath) {
            $vsCodePath  = $userCodePath
            $installType = "User ($($_.Name))"
        }
    }
}

if (-not $vsCodePath) {
    Write-Output "VS Code not installed — no policy enforcement required"
    exit 0
}

try {
    $installedVersion = [Version](Get-Item $vsCodePath).VersionInfo.ProductVersion
}
catch {
    Write-Output "Unable to determine VS Code version — skipping"
    exit 0
}

Write-Output "Found: VS Code ($installType), v$installedVersion"

if ($installedVersion -lt $minimumVersion) {
    Write-Output "Below minimum v$minimumVersion — extension policies not supported"
    exit 0
}

if (Get-ItemProperty -Path $regpath -Name $name -ErrorAction SilentlyContinue) {
    Write-Output "Policy exists — compliant"
    exit 0
}

Write-Output "Policy missing — remediation required"
exit 1
