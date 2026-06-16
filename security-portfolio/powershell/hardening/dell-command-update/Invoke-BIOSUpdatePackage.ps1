<#
.SYNOPSIS
    PSAppDeployToolkit v4 Win32 app — automated Dell BIOS update via Dell Command Update.

.DESCRIPTION
    Deployed as an Intune Win32 app alongside a Proactive Remediation pair
    (Test-BIOSUpdateHeartbeat.ps1 / Invoke-BIOSUpdateRemediation.ps1).

    Workflow:
      Pre-Install : Verify Dell hardware and DCU installation, configure proxy/BIOS
                    password, scan for BIOS/firmware updates.
      Install     : If updates found, prompt user and invoke dcu-cli /applyUpdates.
      Post-Install: Clean up proxy settings, surface exit code 3010 when a reboot
                    is required to complete the BIOS flash.

    A registry heartbeat (HKLM:\SOFTWARE\DELL\DCUAutoBIOSUpdatesLastRun) is stamped
    in ISO 8601 invariant format on every successful or benign run. The Proactive
    Remediation detection script reads this stamp; when it ages past 14 days the
    remediation deletes the key, flipping Intune app detection to "not installed" and
    causing this package to re-run.

.PARAMETER DeploymentType
    Install | Uninstall | Repair. Defaults to Install.

.PARAMETER DeployMode
    Interactive | Silent | NonInteractive. Defaults to Interactive.

.PARAMETER AllowRebootPassThru
    Pass exit code 3010 (reboot required) back to the parent process.

.EXAMPLE
    powershell.exe -File Invoke-BIOSUpdatePackage.ps1 -DeployMode Silent

.NOTES
    Requires: PSAppDeployToolkit v4.0.6+, Dell Command Update installed at
              %ProgramFiles%\Dell\CommandUpdate\dcu-cli.exe
    Sensitive placeholders:
      <BIOS-PASSWORD> — replace with your Dell BIOS supervisor password
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
    AppName              = 'BIOS'
    AppVersion           = ''
    AppArch              = ''
    AppLang              = 'EN'
    AppRevision          = '1.4'
    AppSuccessExitCodes  = @(0)
    AppRebootExitCodes   = @(1641, 3010)
    AppScriptVersion     = '1.0.3'
    AppScriptDate        = '2026-01-01'
    AppScriptAuthor      = 'IT Ops'
    InstallName          = ''
    InstallTitle         = ''
    DeployAppScriptFriendlyName = $MyInvocation.MyCommand.Name
    DeployAppScriptVersion      = '4.1.0'
    DeployAppScriptParameters   = $PSBoundParameters
}

function Install-ADTDeployment {
    ##================================================
    ## MARK: Pre-Install
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    function Set-BIOSHeartbeat {
        # ISO 8601 sortable stamp — must match the format Test-BIOSUpdateHeartbeat.ps1
        # parses with InvariantCulture. Do NOT use 'Get-Date -Format G' (locale-dependent).
        $RunDate = (Get-Date).ToString('s')
        Write-ADTLogEntry -Message "Heartbeat: stamping HKLM\SOFTWARE\DELL\DCUAutoBIOSUpdatesLastRun = $RunDate"
        Set-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\DELL' -Name 'DCUAutoBIOSUpdatesLastRun' -Value $RunDate -Type String
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

    # Configure DCU — proxy depends on whether Always-On VPN is connected
    Write-ADTLogEntry -Message 'Applying DCU configuration including BIOS password'
    & "$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /configure `
        -biosPassword='<BIOS-PASSWORD>' `
        -advancedDriverRestore=enable `
        -autoSuspendBitLocker=enable `
        -scheduleManual `
        -scheduleAction=NotifyAvailableUpdates `
        -updateSeverity='security,critical,recommended'

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

    # DCU returns 5 when a reboot is pending from a previous run
    if ($LASTEXITCODE -eq 5) {
        Write-ADTLogEntry -Message 'DCU exit code 5 — reboot pending. Exiting 3010.'
        Close-ADTSession -ExitCode 3010
    }

    $UpdateType     = 'bios,firmware'
    $UpdateSeverity = 'security,critical,recommended'

    Write-ADTLogEntry -Message 'Scanning for BIOS/firmware updates...'
    $ScanResults = & "$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /scan -updateSeverity="$UpdateSeverity" -updateType="$UpdateType"
    Write-ADTLogEntry -Message $ScanResults

    if ($LASTEXITCODE -eq 500 -or $LASTEXITCODE -eq 3003) {
        if ($LASTEXITCODE -eq 500) { Write-ADTLogEntry -Message 'No BIOS updates available.' }
        if ($LASTEXITCODE -eq 3003) { Write-ADTLogEntry -Message 'DCU service busy.' }
        Set-BIOSHeartbeat
        $Updates = $false
    }
    else {
        Write-ADTLogEntry -Message 'BIOS update available — proceeding.'
        $Updates = $true
    }

    # Battery check — BIOS will not update on battery power
    if ($Updates) {
        $Battery = Get-CimInstance -Class BatteryStatus -Namespace root\wmi -ErrorAction SilentlyContinue
        if ($Battery) {
            $OnMains = [bool](Get-CimInstance -Class BatteryStatus -Namespace root\wmi).PowerOnLine
            if (-not $OnMains) {
                Write-ADTLogEntry -Message 'Device on battery — will not update. Exiting 12003.'
                Close-ADTSession -ExitCode 12003
            }
        }
    }

    ##================================================
    ## MARK: Install
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    $RebootRequired = $false

    if ($Updates) {
        $userChoice = Show-ADTInstallationPrompt `
            -Title 'Dell BIOS Update Required' `
            -Message "A Dell BIOS update is available for your device.`n`nPressing Install Now will download the update in the background. A reboot will be required to complete the BIOS flash.`n`nThis prompt will persist — you are required to install this update." `
            -ButtonMiddleText 'Install Now' `
            -NotTopMost -Icon Information -PersistPrompt -Timeout 28500 -NoExitOnTimeout

        Show-ADTInstallationProgress -StatusMessage 'Installing Dell BIOS update, please wait...' -NotTopMost
        Write-ADTLogEntry -Message "Applying updates. DCU log: $DCULogFile"

        & "$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /applyUpdates `
            -updateSeverity="$UpdateSeverity" -updateType="$UpdateType" -outputLog="$DCULogFile"
        Write-ADTLogEntry -Message "dcu-cli /applyUpdates exit code: $LASTEXITCODE"

        # Stamp heartbeat on success/benign outcomes; leave unstamped on genuine failure
        if ($LASTEXITCODE -in @(0, 1, 5, 500)) { Set-BIOSHeartbeat }

        if ($LASTEXITCODE -eq 1) { $RebootRequired = $true }
        if (Test-Path $DCULogFile) {
            if (Select-String -Path $DCULogFile -Pattern 'requires a reboot' -SimpleMatch) {
                $RebootRequired = $true
            }
        }

        if ($LASTEXITCODE -eq 500) {
            Write-ADTLogEntry -Message 'No update required at apply stage.'
        }
        elseif ($LASTEXITCODE -notin @(0, 1, 5)) {
            Write-ADTLogEntry -Message "Unexpected exit code $LASTEXITCODE. Check DCU log."
            Show-ADTInstallationPrompt -Title 'BIOS Update Did Not Complete' `
                -Message 'If this error persists, please raise an IT support ticket.' -ButtonRightText 'OK'
            Close-ADTSession
        }

        Show-ADTInstallationPrompt -Title 'Download Complete' `
            -Message 'Please reboot your device to install the BIOS update.' -ButtonRightText 'OK'
    }

    ##================================================
    ## MARK: Post-Install
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    if ($CustomProxy) {
        if ($Updates) {
            # Set RunOnce so proxy is cleared after the reboot required for BIOS flash
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
        Write-ADTLogEntry -Message 'Reboot required to complete BIOS flash. Exiting 3010.'
        Set-BIOSHeartbeat
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
