<#

.SYNOPSIS
PSAppDeployToolkit - This script performs the installation or uninstallation of an application(s).

.DESCRIPTION
- The script is provided as a template to perform an install, uninstall, or repair of an application(s).
- The script either performs an "Install", "Uninstall", or "Repair" deployment type.
- The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

The script imports the PSAppDeployToolkit module which contains the logic and functions required to install or uninstall an application.

PSAppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2025 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham, Muhammad Mashwani, Mitch Richters, Dan Gough).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESaS FOR A PARTICULAR PURPOSE. See the GNU General Public License
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
    AppVendor = 'Dell'
    AppName = 'BIOS'
    AppVersion = ''
    AppArch = ''
    AppLang = 'EN'
    AppRevision = '1.4'
    AppSuccessExitCodes = @(0)
    AppRebootExitCodes = @(1641, 3010)
    AppScriptVersion = '1.0.3'
    AppScriptDate = '2026-06-04'
    AppScriptAuthor = 'DB'

    # Install Titles (Only set here to override defaults set by the toolkit).
    InstallName = ''
    InstallTitle = ''

    # Script variables.
    DeployAppScriptFriendlyName = $MyInvocation.MyCommand.Name
    DeployAppScriptVersion = '4.1.0'
    DeployAppScriptParameters = $PSBoundParameters
}

function Install-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Install
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    Function SetRegKey {
            $RunDate = Get-Date -Format G
            Write-ADTLogEntry -Message "Heartbeat: stamping HKLM\SOFTWARE\DELL\DCUAutoBIOSUpdatesLastRun = $RunDate"
            Set-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\DELL' -Name 'DCUAutoBIOSUpdatesLastRun' -Value $runDate -Type String
            }

    ## <Perform Pre-Installation tasks here>
    #Check that we're running on Dell Hardware
		If (-Not (Get-CimInstance -ClassName Win32_Bios | Where-Object {$_.Manufacturer -Like 'Dell*'})) {
			Write-ADTLogEntry -Message 'Dell Hardware NOT detected'
			Write-ADTLogEntry -Message 'Exiting with error code 12000'
			Close-ADTSession -ExitCode 12000
		}

    #Check that Dell Command Update is installed in the expected location
		If (-Not (Test-Path -Path "$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe")) {
			Write-ADTLogEntry -Message 'Dell Command Update is NOT installed'
			Write-ADTLogEntry -Message 'Exiting with error code 12001'
			Close-ADTSession -ExitCode 12001
		}

    #Set registry value to use for Application Detection - Removed as not required when this is being put in Intune as an App.
		#this is intended only to run once and set a registry value, then exit. This prevents DCU running at the time of initial deployment
		#If (-Not(Test-ADTRegistryValue -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\DELL' -Name 'DCUAutoBIOSUpdatesFirstRun')) {
			#Write-ADTLogEntry -Message 'Writing first and current run time information to Registry - HKEY_LOCAL_MACHINE\SOFTWARE\DELL\DCUAutoBIOSUpdatesFirstRun'
			#Set-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\DELL' -Name 'DCUAutoBIOSUpdatesFirstRun' -Value $RunDate -Type String
			#Set-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\DELL' -Name 'DCUAutoBIOSUpdatesLastRun' -Value $RunDate -Type String
			#Write-ADTLogEntry -Message 'First Run - exiting in preparation for scheduled runs'
			#Write-ADTLogEntry -Message 'Exiting with error code 12002'
			#Exit code 12002 added to AppDeployToolkitMain.ps1 to mark successful run
			#Close-ADTSession -ExitCode 12002
		#}
		#the presence of this value will be used for application detection
		#a scheduled SCCM program will periodically delete it, causing the application to run again
		#Write-ADTLogEntry -Message 'Writing current run time information to Registry - HKEY_LOCAL_MACHINE\SOFTWARE\DELL\DCUAutoBIOSUpdatesLastRun'
		#Set-ADTRegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\DELL' -Name 'DCUAutoBIOSUpdatesLastRun' -Value $RunDate -Type String


        #Close Dell Command Update if already running
	    Show-ADTInstallationWelcome -CloseProcesses 'DellCommandUpdate' -CloseProcessesCountdown 180 -PersistPrompt  -NoMinimizeWindows


		#prepare log file path and name for the update process itself
		#DCU must log to this folder %ProgramData%\dell\DellCommandUpdate
		$DCULogPath = "$envProgramData\Dell\DellCommandUpdate"
		$DCULogName = ("Dell_Command_Update" + '_' + $(get-date -f yyyyMMdd) + '.log')
		$DCULogFile = (Join-Path -Path $DCULogPath -ChildPath $DCULogName)

        #set the important settings in case they've been changed or unset
		Write-ADTLogEntry -Message 'Applying Met Office Configuration including BIOS password'
		&"$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /configure -biosPassword='bi0sf1r3' -advancedDriverRestore=enable -autoSuspendBitLocker=enable -scheduleManual -scheduleAction=NotifyAvailableUpdates -updateSeverity='security,critical,recommended'
		#these are the settings split up, for reference:
		#&"$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /configure -biosPassword='bi0sf1r3'
		#&"$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /configure -advancedDriverRestore=enable
		#&"$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /configure -autoSuspendBitLocker=enable
		#&"$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /configure -scheduleManual
		#&"$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /configure -scheduleAction=NotifyAvailableUpdates
		#&"$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /configure -updateSeverity='security,critical,recommended'

        #This should return two results
		#Initialise first so the Post-Install proxy check never references an unset variable under StrictMode
		$CustomProxy = $false
		$AOVPN =(Get-VpnConnection -AllUserConnection).ConnectionStatus

		if ($AOVPN -contains 'Connected') {
			Write-ADTLogEntry -Message 'Device is connected via AOVPN'
			Write-ADTLogEntry -Message 'Disabling custom proxy / Setting IE proxy'
			&"$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /configure -customProxy=disable
		} else {
			Write-ADTLogEntry -Message 'Device is NOT connected to AOVPN'
			Write-ADTLogEntry -Message 'Setting custom Proxy'
			&"$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /configure -proxyHost="webproxy-cloud.metoffice.gov.uk" -proxyPort=8082 -customProxy=enable
			$CustomProxy = $true
		}

        #if DCU needs a reboot (run manually that day for example) then dcu-cli.exe will give error code 5
		if ($lastexitcode -eq 5) {
				Write-ADTLogEntry -Message 'Error 5 detected likely due to reboot needed'
				Write-ADTLogEntry -Message 'Exiting with error code 3010'
				Close-ADTSession -ExitCode 3010
		}

        $UpdateType = 'bios,firmware'
		Write-ADTLogEntry -Message 'The Update Type has been set to BIOS'
        
        #we don't include 'optional'
        $UpdateSeverity = 'security,critical,recommended'

        ## Scan for updates
		Write-ADTLogEntry -Message 'Start Dell Command Update scan...'
		# I had problems capturing results with Execute-Process so I'm just calling the exe with &
		$ScanResults = &"$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /scan -updateSeverity="$UpdateSeverity" -updateType="$UpdateType"
		#$ScanResults = &"$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /scan
		Write-ADTLogEntry -Message $ScanResults
		## Check if updates were found in the scan, and set variables accordingly
        ## Also check if last exit code was 3003 (service busy)
        if ($lastexitcode -eq 500 -Or $lastexitcode -eq 3003) {
			if ($lastexitcode -eq 500) {
				Write-ADTLogEntry -Message 'No BIOS updates are available, finishing up...'
				# Heartbeat: a clean 'no updates' scan is a successfully completed run -> stamp so App detection passes.
				SetRegKey
                Close-ADTSession
			}
			if ($lastexitcode -eq 3003) {
				Write-ADTLogEntry -Message 'The Dell Client Management Service is busy, finishing up...'
				# Heartbeat: mirrors the driver app, which stamps on 'service busy' so a transient busy state is not reported as a failed install.
				# NOTE: a busy result is not strictly a completed scan; if you would rather it retry next cycle instead of waiting 14 days, remove this SetRegKey.
				SetRegKey
                Close-ADTSession
			}
			$Updates = $false
			#(Get-ADTConfig).UI.BalloonNotifications = $false
		} else {
			Write-ADTLogEntry -Message 'There is a BIOS update available, proceeding...'
			$Updates = $true
            #(Get-ADTConfig).UI.BalloonNotifications = $true
		}
    Write-ADTLogEntry $Updates

    If ($Updates) {
			#Check if a battery is present and if we are running on battery power (BIOS will not update without mains power)
			Write-ADTLogEntry 'checking BATTERY status...'
			$Battery = Get-CimInstance -Class BatteryStatus -Namespace root\wmi -ErrorAction SilentlyContinue
			If ($Battery) {
				$OnMains = [boolean](Get-CimInstance -Class BatteryStatus -Namespace root\wmi).PowerOnLine
				If (!($OnMains)) {
					Write-ADTLogEntry 'Device is running on Battery - will NOT proceed'
					Write-ADTLogEntry 'Exiting with error code 12003'
					Close-ADTSession -ExitCode 12003
					#[boolean]$Updates = $false
				}
			}
		}

    ##================================================
    ## MARK: Install
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI installations.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
        if ($adtSession.DefaultMspFiles)
        {
            $adtSession.DefaultMspFiles | Start-ADTMsiProcess -Action Patch
        }
    }

    ## <Perform Installation tasks here>
    if ($Updates -eq $true) {
                    # Show prompt to user: Install or Defer
                    $userChoice = Show-ADTInstallationPrompt `
                    -Title 'Dell BIOS Update Required' `
                    -Message "A Dell BIOS update is available for your device.`n`nPressing Install Now will download the BIOS update in the background. Once this is downloaded, a reboot will be required.`n`nThis prompt will persist, as you are required to install this update." `
                    -ButtonMiddleText 'Install Now' `
                    -NotTopMost `
                    -Icon Information `
                    -PersistPrompt `
                    -Timeout 28500 `
                    -NoExitOnTimeout

                ## Removed the option to defer.
                ##if ($userChoice -eq 'Defer') {
                ##    Write-ADTLogEntry -Message "User chose to defer the Dell BIOS update. Exiting script."
                ##    Close-ADTSession -ExitCode 1618 # Use a custom exit code for deferral if desired
                ##}

                # User chose to install, proceed with BIOS update
                Show-ADTInstallationProgress -StatusMessage "Installing Dell BIOS update, please wait..." -NotTopMost
                Write-ADTLogEntry 'Proceeding with installation of updates...'
				Write-ADTLogEntry "DCU update log is located at $DCULogFile"

                # Insert your Dell BIOS update command here, for example:
                &"$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /applyUpdates -updateSeverity="$UpdateSeverity" -updateType="$UpdateType" -outputLog="$DCULogfile"
                Write-ADTLogEntry "Last exit code is $lastexitcode"
                # Heartbeat: stamp on a successful/benign apply so App detection passes and Intune records the install as succeeded.
                # 0 = success, 1/5 = success (reboot required), 500 = nothing applicable. Any other code is a genuine failure and is left UNSTAMPED so the app retries.
                If ($lastexitcode -eq 0 -or $lastexitcode -eq 1 -or $lastexitcode -eq 5 -or $lastexitcode -eq 500) {
                    SetRegKey
                }
				#check for exit code OR the reboot required info in the log
                $RebootRequired = $false
				If ($lastexitcode -eq 1) {
				    $RebootRequired = $true
				}
				If (Test-Path $DCULogFile) {
					If (Select-String -Path $DCULogFile -Pattern 'requires a reboot' -SimpleMatch) {
					$RebootRequired = $true
					}
				}
				If ($RebootRequired) {
					Write-ADTLogEntry 'Reboot is required'
			        Write-ADTLogEntry 'Exiting with error code 3010'                     
				}

                If ($lastexitcode -eq 500) {
					Write-ADTLogEntry 'No update required, exiting script'                 
				}
                
                Show-ADTInstallationPrompt -Title 'Download Complete' -Message 'Please now reboot your device to install the update.' -ButtonRightText 'OK'

                }
                    else {
                        Write-ADTLogEntry -Message "Cannot complete update, Last Exit code is: $lastexitcode. Please refer to the DCU log for further information."
                        Show-ADTInstallationPrompt -Title 'The BIOS Update did not complete' -Message 'If you are persistently seeing this error, please raise an Incident through ServiceNow.' -ButtonRightText 'OK'
                        Close-ADTSession
                }


    ##================================================
    ## MARK: Post-Install
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Installation tasks here>
    if ($CustomProxy) {
			if ($Updates) {
				#if updates were installed and the proxy was set, we need to set the proxy back to ie proxy on next reboot
				#this is because you get an Error 5 on any actions after updates have been installed
				Write-ADTLogEntry -Message 'Custom proxy was set'
				Write-ADTLogEntry -Message 'Setting RunOnce reg key to disable custom proxy / Set IE proxy on next reboot'
				New-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name 'Disable Dell Command Update custom proxy' -Value '"%ProgramFiles%\Dell\CommandUpdate\dcu-cli.exe" /configure -customProxy=disable' -PropertyType ExpandString -Force
			} else {
				#disable custom proxy now
				Write-ADTLogEntry -Message 'Custom proxy was set'
				Write-ADTLogEntry -Message 'Disabling custom proxy / Setting IE proxy'
				&"$envProgramFiles\Dell\CommandUpdate\dcu-cli.exe" /configure -customProxy=disable
			}
		}

    # Reboot handling re-enabled: surface 3010 so Intune records a pending BIOS flash as 'success, reboot required'.
    # (Previously commented out, so reboot-required runs exited 0 and Intune never learned a reboot was outstanding.)
    If ($RebootRequired) {
			Write-ADTLogEntry 'Updates were found and installed - reboot required to complete the BIOS update'
			#Show-ADTInstallationRestartPrompt -CountdownSeconds 28800 -CountdownNoHideSeconds 600
			Write-ADTLogEntry 'Exiting with error code 3010'
			SetRegKey
			Close-ADTSession -ExitCode 3010
		}
}

function Uninstall-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Uninstall
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing.
    ##Show-ADTInstallationWelcome -CloseProcesses iexplore -CloseProcessesCountdown 60

    ## Show Progress Message (with the default message).
    ##Show-ADTInstallationProgress

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

    ## <Perform Pre-Repair tasks here>


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

    ## <Perform Repair tasks here>


    ##================================================
    ## MARK: Post-Repair
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Repair tasks here>
}


##================================================
## MARK: Initialization
##================================================

# Set strict error handling across entire operation.
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
Set-StrictMode -Version 1

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