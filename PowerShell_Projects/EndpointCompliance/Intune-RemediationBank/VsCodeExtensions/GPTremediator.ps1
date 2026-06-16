try {
    $pkg = Get-AppxPackage -Name "OpenAI.ChatGPT-Desktop" -AllUsers
    if ($pkg) {
        $pkg | Remove-AppxPackage -AllUsers -ErrorAction Stop
        Write-Host "ChatGPT Desktop removed successfully"
        exit 0
    }
    Write-Host "Package not found - nothing to remove"
    exit 0
} catch {
    Write-Host "Removal failed: $($_.Exception.Message)"
    exit 1
}