# WU-Diag - READ-ONLY Windows Update check. No admin needed. Changes nothing.
# Paste into PowerShell, press Enter, copy all output back.#####
$ErrorActionPreference = 'Continue'
$ProgressPreference     = 'SilentlyContinue'

function Write-Section ($Title) {
    Write-Output ""
    Write-Output ("===== $Title " + ('=' * [Math]::Max(0, 55 - $Title.Length)))
}
function Invoke-Check ($Label, [scriptblock]$Block) {
    try { & $Block } catch { Write-Output ("[ERROR] {0}: {1}" -f $Label, $_.Exception.Message) }
}

Write-Section "0. CONTEXT"
Write-Output ("{0}  on {1}  as {2}\{3}" -f (Get-Date), $env:COMPUTERNAME, $env:USERDOMAIN, $env:USERNAME)

Write-Section "1. BUILD (compare to latest CU)"
Invoke-Check "build" {
    $k = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
    "{0}  {1}  Build {2}.{3}" -f $k.ProductName, $k.DisplayVersion, $k.CurrentBuild, $k.UBR
}

Write-Section "2. UPTIME + PENDING REBOOT"
Invoke-Check "uptime" {
    $up  = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    $cbs = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
    $wu  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    $pfr = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -ErrorAction SilentlyContinue).PendingFileRenameOperations
    "Uptime: {0}d {1}h   RebootPending: {2}  (CBS={3} WU={4} FileRename={5})" -f `
        $up.Days, $up.Hours, ($cbs -or $wu -or ($pfr.Count -gt 0)), $cbs, $wu, (@($pfr).Count)
}

Write-Section "3. SERVICES"
Invoke-Check "services" {
    'wuauserv','bits','cryptsvc','UsoSvc','DoSvc' |
        ForEach-Object { Get-Service $_ -ErrorAction SilentlyContinue } |
        Select-Object Name, Status, StartType |
        Format-Table -AutoSize | Out-String -Width 200
}

Write-Section "4. POLICY / WSUS / DEFERRALS (key culprit)"
Invoke-Check "policy" {
    $p = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
    if (Test-Path $p) {
        Get-ItemProperty $p, "$p\AU" -ErrorAction SilentlyContinue |
            Select-Object WUServer, UseWUServer, TargetReleaseVersion, TargetReleaseVersionInfo, ProductVersion,
                DeferQualityUpdates, DeferQualityUpdatesPeriodInDays, PauseQualityUpdatesStartTime,
                BranchReadinessLevel, NoAutoUpdate, AUOptions |
            Format-List | Out-String -Width 200
    } else {
        "No WU policy key (not WSUS/MDM-pinned at this path)."
    }
}

Write-Section "5. LAST SCAN / DOWNLOAD / INSTALL SUCCESS"
Invoke-Check "times" {
    foreach ($phase in 'Detect','Download','Install') {
        $v = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\Results\$phase" -ErrorAction SilentlyContinue).LastSuccessTime
        "{0,-9} {1}" -f $phase, $(if ($v) { $v } else { '<none>' })
    }
}

Write-Section "6. RECENT HOTFIXES (top 10)"
Invoke-Check "hotfix" {
    Get-HotFix | Sort-Object InstalledOn -Descending |
        Select-Object -First 10 HotFixID, InstalledOn |
        Format-Table -AutoSize | Out-String -Width 200
}

Write-Section "7. WU HISTORY (last 15 + HRESULT)"
Invoke-Check "history" {
    $searcher = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher()
    $n = [Math]::Min(15, $searcher.GetTotalHistoryCount())
    if ($n -gt 0) {
        $searcher.QueryHistory(0, $n) | ForEach-Object {
            $result = switch ($_.ResultCode) { 2 {'OK'} 3 {'OK-errs'} 4 {'FAILED'} 5 {'Abort'} default {$_.ResultCode} }
            [pscustomobject]@{
                Date    = $_.Date
                Result  = $result
                HRESULT = ('0x{0:X8}' -f [uint32]($_.HResult -band 0xFFFFFFFF))
                Title   = ($_.Title -replace '\s+',' ')
            }
        } | Format-Table -AutoSize | Out-String -Width 200
    } else { "history empty" }
}

Write-Section "8. BACKLOG (1-5 min; an error here = can't reach update source)"
Invoke-Check "backlog" {
    $result = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher().Search("IsInstalled=0 and IsHidden=0")
    "Not-installed applicable: {0}" -f $result.Updates.Count
    $result.Updates | ForEach-Object {
        "{0,-12} {1}" -f ($_.KBArticleIDs -join ','), ($_.Title -replace '\s+',' ')
    }
}

Write-Section "9. DISK C:"
Invoke-Check "disk" {
    Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" | ForEach-Object {
        "Free {0} GB of {1} GB ({2}%)" -f [math]::Round($_.FreeSpace/1GB,1), [math]::Round($_.Size/1GB,1), [math]::Round($_.FreeSpace/$_.Size*100,1)
    }
}

Write-Section "10. WU CLIENT ERRORS/WARNINGS (last 15)"
Invoke-Check "events" {
    Get-WinEvent -FilterHashtable @{ LogName='System'; ProviderName='Microsoft-Windows-WindowsUpdateClient' } -MaxEvents 50 -ErrorAction SilentlyContinue |
        Where-Object { $_.LevelDisplayName -in 'Error','Warning' } |
        Select-Object -First 15 TimeCreated, Id, LevelDisplayName,
            @{ n='Msg'; e={ ($_.Message -replace '\s+',' ').Substring(0, [Math]::Min(150, ($_.Message -replace '\s+',' ').Length)) } } |
        Format-Table -AutoSize -Wrap | Out-String -Width 200
}

Write-Section "11. CONNECTIVITY"
Invoke-Check "network" {
    $wu = (Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -ErrorAction SilentlyContinue).WUServer
    if ($wu) {
        $u = [Uri]$wu
        $port = if ($u.Port -gt 0) { $u.Port } elseif ($u.Scheme -eq 'https') { 443 } else { 8530 }
        $t = Test-NetConnection $u.Host -Port $port -WarningAction SilentlyContinue
        "WSUS {0}:{1}  TCP_OK={2}" -f $u.Host, $port, $t.TcpTestSucceeded
    } else {
        "No WSUS set -> uses Windows Update online"
    }
    foreach ($h in 'fe3cr.delivery.mp.microsoft.com','www.microsoft.com') {
        $t = Test-NetConnection $h -Port 443 -WarningAction SilentlyContinue
        "{0,-40} TCP443_OK={1}" -f $h, $t.TcpTestSucceeded
    }
}

Write-Section "DONE - copy everything above and paste it back"