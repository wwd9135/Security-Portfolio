@{
    Assets = @{
        # Filename of the application icon shown in PSADT dialogs.
        Logo   = '..\Assets\AppIcon.png'

        # Filename of the banner image (Classic dialog style only).
        Banner = '..\Assets\Banner.Classic.png'
    }

    MSI = @{
        # Parameters for non-silent MSI installs.
        InstallParams = 'REBOOT=ReallySuppress /QB-!'

        # MSI logging verbosity flag.
        LoggingOptions = '/L*V'

        # Log path for MSI operations (admin context).
        LogPath = '$envWinDir\Logs\Software'

        # Log path when RequireAdmin = $false.
        LogPathNoAdminRights = '$envProgramData\Logs\Software'

        # Seconds to wait for the MSI installer service mutex. Default: 600 (10 min).
        MutexWaitTime = 600

        # Parameters for silent MSI installs.
        SilentParams = 'REBOOT=ReallySuppress /QN'

        # Parameters for MSI uninstall actions.
        UninstallParams = 'REBOOT=ReallySuppress /QN'
    }

    Toolkit = @{
        # Local cache folder for staged deployment files.
        CachePath = '$envProgramData\SoftwareCache'

        # Compress log folder into a zip on completion.
        CompressLogs = $false

        # 'Native' = Copy-ADTItem; 'Robocopy' = robocopy.exe.
        FileCopyMode = 'Native'

        # Append to an existing log file rather than overwriting.
        LogAppend = $true

        # Include verbose debug messages (bound parameters, etc.) in the log.
        LogDebugMessage = $false

        # Number of previous log files to keep.
        LogMaxHistory = 10

        # Maximum log file size in megabytes before rotation.
        LogMaxSize = 10

        # Log path (admin context).
        LogPath = '$envWinDir\Logs\Software'

        # Log path when RequireAdmin = $false.
        LogPathNoAdminRights = '$envProgramData\Logs\Software'

        # Create a per-InstallName subfolder under LogPath.
        LogToSubfolder = $false

        # 'CMTrace' for CMTrace-compatible log format; 'Legacy' for plain text.
        LogStyle = 'CMTrace'

        # Echo log messages to the PowerShell host console.
        LogWriteToHost = $true

        # Write console log output directly to stdout/stderr (bypasses PS subsystem).
        # Only applies when LogWriteToHost = $true and running in ConsoleHost.
        LogHostOutputToStdStreams = $false

        # Switch DeployMode to Silent during Windows Out-of-Box Experience (OOBE).
        OobeDetection = $true

        # Registry root for toolkit data (deferral history, etc.).
        RegPath = 'HKLM:\SOFTWARE'

        # Registry root when RequireAdmin = $false (user-writable; accept the security trade-off).
        RegPathNoAdminRights = 'HKCU:\SOFTWARE'

        # Require elevation for the deployment. Some functions (deferral, block-exec, logging) need this.
        RequireAdmin = $true

        # Switch DeployMode to NonInteractive when running as SYSTEM (session 0).
        SessionDetection = $true

        # Temp folder for toolkit scratch files. Defaults to LocalSystem's %TEMP% (C:\Windows\Temp).
        TempPath = '$envTemp'

        # Temp path when RequireAdmin = $false.
        TempPathNoAdminRights = '$envTemp'
    }

    UI = @{
        # Show balloon notifications from the system tray.
        BalloonNotifications = $true

        # Title text for balloon notifications.
        BalloonTitle = 'PSAppDeployToolkit'

        # 'Fluent' = modern PSADT v4 dialogs; 'Classic' = PSADT 3.x WinForms dialogs.
        DialogStyle = 'Fluent'

        # Exit code returned when a UI prompt times out.
        DefaultExitCode = 1618

        # Seconds between repositioning PersistPrompt dialogs to centre-screen.
        DefaultPromptPersistInterval = 60

        # Seconds before installation dialogs auto-close.
        # Default 3300 s (55 min) ensures timeout before Intune's 60-min deadline.
        DefaultTimeout = 3300

        # Exit code returned when a user chooses to defer the installation.
        DeferExitCode = 60012

        # Re-enumerate running processes while the Welcome prompt is visible.
        DynamicProcessEvaluation = $true

        # Interval in seconds for the dynamic process re-check.
        DynamicProcessEvaluationInterval = 2

        # Override auto-detected UI language. Null = use system culture.
        # Supported codes: AR, CZ, DA, DE, EN, EL, ES, FI, FR, HE, HU, IT, JA,
        #                  KO, NL, NB, PL, PT, PT-BR, RU, SK, SV, TR, ZH-Hans, ZH-Hant
        LanguageOverride = $null

        # Seconds to wait for apps to save before re-prompting on close.
        PromptToSaveTimeout = 120

        # Seconds between repositioning the restart prompt when -NoCountdown is used.
        RestartPromptPersistInterval = 600
    }
}
