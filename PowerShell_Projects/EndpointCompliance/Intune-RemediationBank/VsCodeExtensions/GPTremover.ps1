$pkg = Get-AppxPackage -Name "OpenAI.ChatGPT-Desktop" -AllUsers -ErrorAction SilentlyContinue
if ($pkg) {
    Write-Host "ChatGPT Desktop found: $($pkg.PackageFullName)"
    exit 1
} else {
    Write-Host "ChatGPT Desktop not present"
    exit 0
}