<#
.SYNOPSIS
    PSAppDeployToolkit v4 package — configures a BitLocker TPM+PIN protector via a GUI.

.DESCRIPTION
    Deploys a Windows Forms GUI (BitLockerPINModule.psm1) that collects and validates a
    user-supplied PIN, then applies it as the TPM+PIN protector on all fully-encrypted
    BitLocker volumes.

    PIN complexity is read from native FVE registry policy:
      HKLM:\SOFTWARE\Policies\Microsoft\FVE\MinimumPIN      (default 6 if absent)
      HKLM:\SOFTWARE\Policies\Microsoft\FVE\UseEnhancedPin  (alphanumeric if 1)

    Validation rules enforced by the module:
      - Length between MinimumPIN and 20 characters
      - No 3-character ascending or descending sequences (e.g. abc, 123, cba)
      - No 3 consecutive repeated characters (e.g. aaa, 111)
      - Must contain at least 2 character types when EnhancedPIN is on
      - Not in the common password list (PassList.txt)

    Exit codes:
      0    = PIN set successfully
      1    = BitLocker volume error or protector add failure
      1602 = User cancelled
      60001 = Unhandled toolkit error

.PARAMETER DeploymentType
    Install | Uninstall | Repair  (default: Install)

.PARAMETER DeployMode
    Interactive | Silent | NonInteractive  (default: Interactive)

.PARAMETER AllowRebootPassThru
    Passes exit code 3010 back to the parent process.

.PARAMETER TerminalServerMode
    Sets user-install mode for RDS/Citrix environments.

.PARAMETER DisableLogging
    Suppresses toolkit file logging.

.NOTES
    Framework : PSAppDeployToolkit v4.0.6
    Author    : IT Ops
    Vendor    : Contoso
    Version   : 1.0.0
    Date      : 2025-06-01
#>

[CmdletBinding()]
param
(
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
    AppVendor            = 'Contoso'
    AppName              = 'Set BitLocker PIN'
    AppVersion           = ''
    AppArch              = ''
    AppLang              = 'EN'
    AppRevision          = '01'
    AppSuccessExitCodes  = @(0)
    AppRebootExitCodes   = @(1641, 3010)
    AppScriptVersion     = '1.0.0'
    AppScriptDate        = '2025-06-01'
    AppScriptAuthor      = 'IT Ops'

    InstallName          = 'Set BitLocker PIN'
    InstallTitle         = 'Set BitLocker PIN'

    DeployAppScriptFriendlyName = $MyInvocation.MyCommand.Name
    DeployAppScriptVersion      = '4.0.6'
    DeployAppScriptParameters   = $PSBoundParameters
}

$ModulePath = Join-Path $PSScriptRoot 'Files\BitLockerPINModule.psm1'
Import-Module $ModulePath -Force -ErrorAction Stop

function Install-ADTDeployment {
    ##================================================
    ## MARK: Pre-Install
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    $buttonChoice = Show-ADTInstallationPrompt `
        -Title   'Set BitLocker PIN Code' `
        -Message "BitLocker is a Windows feature providing encryption.
BitLocker requires a PIN code that must be entered every time your computer is started up. This PIN code is of your own choice.
`nWhen you click 'I'm Ready' a text box will appear. When prompted, please enter an alphanumeric PIN code of 8 characters or more, then click 'Set PIN' to complete the process." `
        -Icon         Warning `
        -PersistPrompt `
        -ButtonMiddleText "I'm Ready" `
        -ButtonRightText  'Cancel'

    Write-ADTLogEntry -Message "User selected: $buttonChoice"
    if ($buttonChoice -eq 'Cancel') {
        Write-ADTLogEntry -Message 'User cancelled at initial prompt.'
        Exit 1602
    }

    BitLockerGuiLauncher

    if ($global:UserCancelled) {
        Write-ADTLogEntry -Message 'User cancelled in PIN GUI.'
        Exit 1602
    }

    ##================================================
    ## MARK: Installation
    ##================================================
    try {
        $BitLockerVolumes = Get-BitLockerVolume | Where-Object { $_.VolumeStatus -eq 'FullyEncrypted' }
        if (-not $BitLockerVolumes) {
            Write-ADTLogEntry 'No fully-encrypted BitLocker volumes found.'
            Exit 1
        }

        foreach ($Vol in $BitLockerVolumes) {
            $MountPoint = $Vol.MountPoint
            Write-ADTLogEntry "Processing drive $MountPoint..."

            Suspend-BitLocker -MountPoint $MountPoint -RebootCount 1
            Write-ADTLogEntry "Suspended BitLocker on $MountPoint"

            $Protector = $Vol.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'TpmPin' }
            if ($Protector) {
                Write-ADTLogEntry 'Removing existing TPM+PIN protector...'
                Remove-BitLockerKeyProtector -MountPoint $MountPoint -KeyProtectorId $Protector.KeyProtectorId
            }
            else {
                Write-ADTLogEntry 'No existing TPM+PIN protector — skipping remove step.'
            }

            try {
                Add-BitLockerKeyProtector -MountPoint $MountPoint -TpmAndPinProtector -Pin $global:securePin
                Write-ADTLogEntry "New TPM+PIN protector added on $MountPoint"
            }
            catch {
                Write-ADTLogEntry "Failed to add TPM+PIN protector: $_"
                Exit 1
            }

            Resume-BitLocker -MountPoint $MountPoint
            Write-ADTLogEntry "Resumed BitLocker on $MountPoint"
        }

        Show-ADTInstallationPrompt -Message 'BitLocker PIN updated successfully.' -ButtonRightText 'OK'
        Exit 0
    }
    catch {
        Write-ADTLogEntry "Failure while modifying BitLocker PIN: $_"
        Exit 1
    }

    ##================================================
    ## MARK: Post-Install
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"
    Show-ADTInstallationPrompt `
        -Title           'Set BitLocker PIN Code' `
        -Icon            Shield `
        -NoWait `
        -Message         'You have successfully set your BitLocker PIN. This PIN is required whenever your computer starts up.' `
        -ButtonMiddleText 'Finish'
}

function Uninstall-ADTDeployment {
    ##================================================
    ## MARK: Pre-Uninstall
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"
    Show-ADTInstallationWelcome -CloseProcesses iexplore -CloseProcessesCountdown 60
    Show-ADTInstallationProgress

    ##================================================
    ## MARK: Uninstall
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType
    if ($adtSession.UseDefaultMsi) {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile) }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
    }

    ##================================================
    ## MARK: Post-Uninstall
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"
}

function Repair-ADTDeployment {
    ##================================================
    ## MARK: Pre-Repair
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"
    Show-ADTInstallationWelcome -CloseProcesses iexplore -CloseProcessesCountdown 60
    Show-ADTInstallationProgress

    ##================================================
    ## MARK: Repair
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType
    if ($adtSession.UseDefaultMsi) {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile) }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
    }

    ##================================================
    ## MARK: Post-Repair
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"
}

##================================================
## MARK: Initialization
##================================================

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$ProgressPreference    = [System.Management.Automation.ActionPreference]::SilentlyContinue
Set-StrictMode -Version 2

try {
    $moduleName = if ([System.IO.File]::Exists("$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1")) {
        Get-ChildItem -LiteralPath $PSScriptRoot\PSAppDeployToolkit -Recurse -File | Unblock-File -ErrorAction Ignore
        "$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"
    }
    else {
        'PSAppDeployToolkit'
    }
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
    Get-Item -Path $PSScriptRoot\PSAppDeployToolkit.* | & {
        process {
            Get-ChildItem -LiteralPath $_.FullName -Recurse -File | Unblock-File -ErrorAction Ignore
            Import-Module -Name $_.FullName -Force
        }
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
