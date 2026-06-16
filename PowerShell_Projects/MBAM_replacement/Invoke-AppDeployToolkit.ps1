<#
This script uses the PSAppDeployToolkit framework to deploy and execute a secure BitLocker startup PIN configuration.

It runs with administrative privileges via the Intune PSAppDeployToolkit deployment model (SYSTEM context),
and has been security reviewed with all identified issues and some remediated.

The script presents a Windows Forms GUI that enforces organisational BitLocker PIN policies and securely
collects user input before applying the configuration.

#>


<#.SYNOPSIS
PSAppDeployToolkit - This script performs the installation or uninstallation of an application(s).

.DESCRIPTION
- The script is provided as a template to perform an install, uninstall, or repair of an application(s).
- The script either performs an "Install", "Uninstall", or "Repair" deployment type.
- The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

The script imports the PSAppDeployToolkit module which contains the logic and functions required to install or uninstall an application.

PSAppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2025 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham, Muhammad Mashwani, Mitch Richters, Dan Gough).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License\
for more details. You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

.PARAMETER DeploymentType
The type of deployment to perform.

.PARAMETER DeployMode
Specifies whether the installation should be run in Interactive (shows dialogs), Silent (no dialogs), or NonInteractive (dialogs without prompts) mode.

NonInteractive mode is automatically set if it is detected that the process is not user interactive.

.PARAMETER AllowRebootPassThru
Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

.PARAMETER TerminalServerMode
Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Desktop Session Hosts/Citrix servers.

.PARAMETER DisableLogging
Disables logging to file for the script.

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeployMode Silent

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -AllowRebootPassThru

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall

.EXAMPLE
Invoke-AppDeployToolkit.exe -DeploymentType "Install" -DeployMode "Silent"

.INPUTS
None. You cannot pipe objects to this script.

.OUTPUTS
None. This script does not generate any output.

.NOTES
Toolkit Exit Code Ranges:
- 60000 - 68999: Reserved for built-in exit codes in Invoke-AppDeployToolkit.ps1, and Invoke-AppDeployToolkit.exe
- 69000 - 69999: Recommended for user customized exit codes in Invoke-AppDeployToolkit.ps1
- 70000 - 79999: Recommended for user customized exit codes in PSAppDeployToolkit.Extensions module.

.LINK
https://psappdeploytoolkit.com

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
    # App variables.
    AppVendor = 'WR'
    AppName = 'Set BitLocker Pin'
    AppVersion = ''
    AppArch = ''
    AppLang = 'EN'
    AppRevision = '01'
    AppSuccessExitCodes = @(0)
    AppRebootExitCodes = @(1641, 3010)
    AppScriptVersion = '1.0.0'
    AppScriptDate = '2025-06-01'
    AppScriptAuthor = 'William richardson'

    # Install Titles (Only set here to override defaults set by the toolkit).
    InstallName = 'Set BitLocker PIN'
    InstallTitle = 'Set BitLocker PIN'

    # Script variables.
    DeployAppScriptFriendlyName = $MyInvocation.MyCommand.Name
    DeployAppScriptVersion = '4.0.6'
    DeployAppScriptParameters = $PSBoundParameters
}
# Module contains input filtering logic & all GUI related code.
$ModulePath = Join-Path $PSScriptRoot "Files\mod.psm1"
Import-Module $ModulePath -Force -ErrorAction Stop

function Install-ADTDeployment {
    ##================================================
    ## MARK: Pre-Install
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType
    $buttonChoice = Show-ADTInstallationPrompt `
    -Title 'Set BitLocker PIN Code' `
    -Message "BitLocker is a Windows feature providing encryption.
BitLocker requires a PIN code that must be entered every time your computer is started up. This PIN code is of your own choice.
`nWhen you click 'I'm Ready' a text box will appear. When prompted, please enter an alphanumeric PIN code of 8 characters or more, then click 'Set PIN' to complete the process." `
        -Icon Warning `
        -PersistPrompt `
        -ButtonMiddleText "I'm Ready" `
        -ButtonRightText "Cancel"
    
    Write-ADTLogEntry -Message "User selected: $buttonChoice"
    If ($buttonChoice -eq "Cancel") {
        Write-ADTLogEntry -Message "User canceled installation at initial popup."
        Exit 1602  
    }
    BitLockerGuiLauncher

    if ($global:UserCancelled) {
        Write-ADTLogEntry -Message "User canceled installation during popup."
        Exit 1602  
    }

    ##================================================
    ## MARK: Installation
    ##================================================
    # Important section: Modify BitLocker PIN code
    try {
        $BitLockerVolumes = Get-BitLockerVolume | Where-Object { $_.VolumeStatus -eq "FullyEncrypted" }
        if (-not $BitLockerVolumes) {
            Write-ADTLogEntry "No BitLocker volumes found."
            Exit 1
        }

        foreach ($Vol in $BitLockerVolumes) {
            $MountPoint = $Vol.MountPoint
            Write-ADTLogEntry "Processing drive $MountPoint ..."

            Suspend-BitLocker -MountPoint $MountPoint -RebootCount 1
            Write-ADTLogEntry "Suspended BitLocker on $MountPoint"

            $Protector = $Vol.KeyProtector | Where-Object { $_.KeyProtectorType -eq "TpmPin" }
            if ($Protector) {
                Write-ADTLogEntry "Removing existing TPM+PIN protector..."
                Remove-BitLockerKeyProtector -MountPoint $MountPoint -KeyProtectorId $Protector.KeyProtectorId
            } else {
                Write-ADTLogEntry "No TPM+PIN protector found, skipping remove step."
            }

            try {
                Add-BitLockerKeyProtector -MountPoint $MountPoint -TpmAndPinProtector -Pin $global:securePin
                Write-ADTLogEntry "New TPM+PIN protector added successfully on $MountPoint"
            }
            catch {
                Write-ADTLogEntry "Failed to add TPM+PIN protector: $_"
                Exit 1
            }

            Resume-BitLocker -MountPoint $MountPoint
            Write-ADTLogEntry "Resumed BitLocker on $MountPoint"
        }

        Show-ADTInstallationPrompt -Message "BitLocker PIN updated successfully." -ButtonRightText "OK"
        Exit 0
    }
    catch {
        Write-ADTLogEntry "Failure while modifying BitLocker code. $_"
        Exit 1
    }

    ##================================================
    ## MARK: Post-Install
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"
    Show-ADTInstallationPrompt -Title 'Set BitLocker PIN Code' -Icon Shield -NoWait `
        -Message 'You have successfully reset your BitLocker PIN code. This is now required whenever your computer starts up.' `
        -ButtonMiddleText 'Finish'
}

    function Uninstall-ADTDeployment
    {
        ##================================================
        ## MARK: Pre-Uninstall
        ##================================================
        $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

        ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing.
        Show-ADTInstallationWelcome -CloseProcesses iexplore -CloseProcessesCountdown 60

        ## Show Progress Message (with the default message).
        Show-ADTInstallationProgress

        ## <Perform Pre-Uninstallation tasks here>


        ##================================================
        ## MARK: Uninstall
        ##================================================
        $adtSession.InstallPhase = $adtSession.DeploymentType

        ## Handle Zero-Config MSI uninstallations.
        if ($adtSession.UseDefaultMsi)
        {
            $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
            if ($adtSession.DefaultMstFile)
            {
                $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
            }
            Start-ADTMsiProcess @ExecuteDefaultMSISplat
        }

        ## <Perform Uninstallation tasks here>


    ##================================================
    ## MARK: Post-Uninstallation
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Uninstallation tasks here>
}

function Repair-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Repair
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"
    ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing.
    Show-ADTInstallationWelcome -CloseProcesses iexplore -CloseProcessesCountdown 60
    ## Show Progress Message (with the default message).
    Show-ADTInstallationProgress
    
    ##================================================
    ## MARK: Repair
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI repairs.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
        }
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

# Set strict error handling across entire operation.
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
Set-StrictMode -Version 2

# Import the module and instantiate a new session.
try
{
    $moduleName = if ([System.IO.File]::Exists("$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"))
    {
        Get-ChildItem -LiteralPath $PSScriptRoot\PSAppDeployToolkit -Recurse -File | Unblock-File -ErrorAction Ignore
        "$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"
    }
    else
    {
        'PSAppDeployToolkit'
    }
    Import-Module -FullyQualifiedName @{ ModuleName = $moduleName; Guid = '8c3c366b-8606-4576-9f2d-4051144f7ca2'; ModuleVersion = '4.0.6' } -Force
    try
    {
        $iadtParams = Get-ADTBoundParametersAndDefaultValues -Invocation $MyInvocation
        $adtSession = Open-ADTSession -SessionState $ExecutionContext.SessionState @adtSession @iadtParams -PassThru
    }
    catch
    {
        Remove-Module -Name PSAppDeployToolkit* -Force
        throw
    }
}
catch
{
    $Host.UI.WriteErrorLine((Out-String -InputObject $_ -Width ([System.Int32]::MaxValue)))
    exit 60008
}


##================================================
## MARK: Invocation
##================================================

try
{
    Get-Item -Path $PSScriptRoot\PSAppDeployToolkit.* | & {
        process
        {
            Get-ChildItem -LiteralPath $_.FullName -Recurse -File | Unblock-File -ErrorAction Ignore
            Import-Module -Name $_.FullName -Force
        }
    }
    & "$($adtSession.DeploymentType)-ADTDeployment"
    Close-ADTSession
}
catch
{
    Write-ADTLogEntry -Message ($mainErrorMessage = Resolve-ADTErrorRecord -ErrorRecord $_) -Severity 3
    Show-ADTDialogBox -Text $mainErrorMessage -Icon Stop | Out-Null
    Close-ADTSession -ExitCode 60001
}
finally
{
    Remove-Module -Name PSAppDeployToolkit* -Force
}

