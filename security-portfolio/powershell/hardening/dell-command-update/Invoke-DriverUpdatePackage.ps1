<#
.SYNOPSIS
    PSAppDeployToolkit v4 Win32 app — automated Dell driver update via Dell Command Update.

.DESCRIPTION
    Deployed as an Intune Win32 app alongside a Proactive Remediation pair
    (Test-DriverUpdateHeartbeat.ps1 / Invoke-DriverUpdateRemediation.ps1).

    Workflow:
      Pre-Install : Verify Dell hardware and DCU installation, configure proxy,
                    scan for driver/application/utility updates.
      Install     : If updates found, prompt user and invoke dcu-cli /applyUpdates.
      Post-Install: Clean up proxy settings, surface exit code 3010 if reboot needed.

    A registry heartbeat (HKLM:\SOFTWARE\DELL\DCUAutoDriverUpdatesLastRun) is stamped
    in ISO 8601 invariant format on every successful or benign run. The Proactive
    Remediation detection script reads this stamp; when it ages past 14 days the
    remediation deletes the key, causing this package to re-run.

.PARAMETER DeploymentType
    Install | Uninstall | Repair. Defaults to Install.

.PARAMETER DeployMode
    Interactive | Silent | NonInteractive. Defaults to Interactive.

.PARAMETER AllowRebootPassThru
    Pass exit code 3010 (reboot required) back to the parent process.

.EXAMPLE
    powershell.exe -File Invoke-DriverUpdatePackage.ps1 -DeployMode Silent

.NOTES
    Requires: PSAppDeployToolkit v4.0.6+, Dell Command Update installed at
              %ProgramFiles%\Dell\CommandUpdate\dcu-cli.exe
    Sensitive placeholder:
      proxy.contoso.com — replace with your corporate proxy hostname
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [PSDefaultValue(Help = 'Install', Value = 'Install')]
    [System.String]$DeploymentType,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [PSDefaultValue(Help = 'Interactive', Value = 'Interactive')]
    [System.String]$DeployMode,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$AllowRebootPassThru,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$TerminalServerMode,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$DisableLogging
)

##================================================
## MARK: Variables
##================================================

$adtSession = @{
    AppVendor            = 'Dell'
    AppName              = 'Drivers'
    AppVersion           = ''
    AppArch              = ''
    AppLang              = 'EN'
    AppRevision          = '1.3'
    AppSuccessExitCodes  = @(0)
    AppRebootExitCodes   = @(1641, 3010)
    AppScriptVersion     = '1.0.3'
    AppScriptDate        = '2026-01-01'
    AppScriptAuthor      = 'IT Ops'
    InstallName          = ''
    InstallTitle         = ''
    DeployAppScriptFriendlyName = $MyInvocation.MyCommand.Name
    DeployAppScriptVersion      = '4.0.6'
    DeployAppScriptParameters   = $PSBoundParameters
}

function Install-ADTDeployment {
    ##================================================
    ## MARK: Pre-Install
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    function Set-DriverHeartbeat {
        # ISO 8601 sortable stamp — must match the format Test-DriverUpdateHeartbeat.ps1
        # parses with InvariantCulture. Do NOT use 'Get-Date -Format G' (locale-dependent).
        $RunDate = (Get-Date).ToString('s')
        Write-ADTLogEntry -Message "Heartbeat: stamping HKLM\SOFTWARE\DELL\DCUAutoDriverUpdatesLastRun = $RunDate"
        Set-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\DELL' -Name 'DCUAutoDriverUpdatesLastRun' -Value $RunDate -Type String
    }

    # Verify Dell hardware
    if (-Not (Get-CimInstance -ClassName Win32_Bios | Where-Object { $_.Manufacturer -Like 'Dell*' })) {
        Write-ADTLogEntry -Message 'Dell hardware NOT detected. Exiting 12000.'
        Close-ADTSession -ExitCode 12000
    }

    # Verify DCU installation
    if (-Not (Test-Path "$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe")) {
        Write-ADTLogEntry -Message 'Dell Command Update not found. Exiting 12001.'
        Close-ADTSession -ExitCode 12001
    }

    # Close DCU if running
    Show-ADTInstallationWelcome -CloseProcesses 'DellCommandUpdate' -CloseProcessesCountdown 180 -PersistPrompt -NoMinimizeWindows

    # Prepare DCU log path
    $DCULogPath = "$envProgramData\Dell\DellCommandUpdate"
    $DCULogName = "Dell_Command_Update_$(Get-Date -f yyyyMMdd).log"
    $DCULogFile = Join-Path $DCULogPath $DCULogName

    # Configure proxy based on Always-On VPN status
    $CustomProxy = $false
    $AOVPN = (Get-VpnConnection -AllUserConnection -ErrorAction SilentlyContinue).ConnectionStatus

    if ($AOVPN -contains 'Connected') {
        Write-ADTLogEntry -Message 'Always-On VPN connected — disabling custom proxy'
        & "$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /configure -customProxy=disable
    }
    else {
        Write-ADTLogEntry -Message 'Always-On VPN not connected — enabling corporate proxy'
        & "$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /configure -proxyHost='proxy.contoso.com' -proxyPort=8082 -customProxy=enable
        $CustomProxy = $true
    }

    $UpdateType     = 'driver,application,utility,others'
    $UpdateSeverity = 'security,critical,recommended'

    Write-ADTLogEntry -Message 'Scanning for driver updates...'
    $ScanResults = & "$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /scan -updateSeverity="$UpdateSeverity" -updateType="$UpdateType"
    Write-ADTLogEntry -Message $ScanResults

    if ($LASTEXITCODE -eq 500 -or $LASTEXITCODE -eq 3003) {
        if ($LASTEXITCODE -eq 500) { Write-ADTLogEntry -Message 'No driver updates available.' }
        if ($LASTEXITCODE -eq 3003) { Write-ADTLogEntry -Message 'DCU service busy.' }
        Set-DriverHeartbeat
        $Updates = $false
    }
    else {
        Write-ADTLogEntry -Message 'Driver update(s) available — proceeding.'
        Set-DriverHeartbeat
        $Updates = $true
    }

    ##================================================
    ## MARK: Install
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    $RebootRequired = $false

    if ($Updates) {
        $userChoice = Show-ADTInstallationPrompt `
            -Title 'Dell Driver Updates Available' `
            -Message "Dell driver update(s) are available for your device.`n`nDepending on the drivers being installed your screen may flash or the network connection may temporarily disconnect.`n`nPressing Install Now will download and install the update(s) in the background.`n`nThis prompt will persist — you are required to install the update(s)." `
            -ButtonMiddleText 'Install Now' `
            -NotTopMost -Icon Information -PersistPrompt -Timeout 28500 -NoExitOnTimeout

        Show-ADTInstallationProgress -StatusMessage 'Installing Dell driver update(s), please wait...' -NotTopMost
        Write-ADTLogEntry -Message "Applying updates. DCU log: $DCULogFile"

        & "$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /applyUpdates `
            -updateSeverity="$UpdateSeverity" -updateType="$UpdateType" -outputLog="$DCULogFile"
        Write-ADTLogEntry -Message "dcu-cli /applyUpdates exit code: $LASTEXITCODE"

        if ($LASTEXITCODE -eq 1) { $RebootRequired = $true }
        if (Test-Path $DCULogFile) {
            if (Select-String -Path $DCULogFile -Pattern 'requires a reboot' -SimpleMatch) {
                $RebootRequired = $true
            }
        }

        if ($RebootRequired) {
            Set-DriverHeartbeat
            Write-ADTLogEntry -Message 'Reboot required after driver install.'
        }
    }

    ##================================================
    ## MARK: Post-Install
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    if ($CustomProxy) {
        if ($Updates) {
            New-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' `
                -Name 'Disable Dell Command Update custom proxy' `
                -Value '"%ProgramFiles%\Dell\CommandUpdate\dcu-cli.exe" /configure -customProxy=disable' `
                -PropertyType ExpandString -Force | Out-Null
        }
        else {
            & "$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /configure -customProxy=disable
        }
    }

    if ($RebootRequired) {
        Write-ADTLogEntry -Message 'Exiting 3010 — reboot required to complete driver update.'
        Set-DriverHeartbeat
        Close-ADTSession -ExitCode 3010
    }
}

function Uninstall-ADTDeployment {
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"
    $adtSession.InstallPhase = $adtSession.DeploymentType
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"
}

function Repair-ADTDeployment {
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"
    Show-ADTInstallationWelcome -CloseProcesses iexplore -CloseProcessesCountdown 60
    Show-ADTInstallationProgress
    $adtSession.InstallPhase = $adtSession.DeploymentType
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"
}

##================================================
## MARK: Initialization
##================================================

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$ProgressPreference    = [System.Management.Automation.ActionPreference]::SilentlyContinue
Set-StrictMode -Version 1

try {
    $moduleName = if ([System.IO.File]::Exists("$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1")) {
        Get-ChildItem -LiteralPath "$PSScriptRoot\PSAppDeployToolkit" -Recurse -File | Unblock-File -ErrorAction Ignore
        "$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"
    }
    else { 'PSAppDeployToolkit' }

    Import-Module -FullyQualifiedName @{
        ModuleName    = $moduleName
        Guid          = '8c3c366b-8606-4576-9f2d-4051144f7ca2'
        ModuleVersion = '4.0.6'
    } -Force

    try {
        $iadtParams = Get-ADTBoundParametersAndDefaultValues -Invocation $MyInvocation
        $adtSession = Open-ADTSession -SessionState $ExecutionContext.SessionState @adtSession @iadtParams -PassThru
    }
    catch {
        Remove-Module -Name PSAppDeployToolkit* -Force
        throw
    }
}
catch {
    $Host.UI.WriteErrorLine((Out-String -InputObject $_ -Width ([System.Int32]::MaxValue)))
    exit 60008
}

##================================================
## MARK: Invocation
##================================================

try {
    Get-Item -Path "$PSScriptRoot\PSAppDeployToolkit.*" | ForEach-Object {
        Get-ChildItem -LiteralPath $_.FullName -Recurse -File | Unblock-File -ErrorAction Ignore
        Import-Module -Name $_.FullName -Force
    }
    & "$($adtSession.DeploymentType)-ADTDeployment"
    Close-ADTSession
}
catch {
    Write-ADTLogEntry -Message ($mainErrorMessage = Resolve-ADTErrorRecord -ErrorRecord $_) -Severity 3
    Show-ADTDialogBox -Text $mainErrorMessage -Icon Stop | Out-Null
    Close-ADTSession -ExitCode 60001
}
finally {
    Remove-Module -Name PSAppDeployToolkit* -Force
}
