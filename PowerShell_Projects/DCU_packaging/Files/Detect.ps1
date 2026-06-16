# Get driver info
$Driver = Get-WmiObject Win32_PnPSignedDriver | Where-Object {
    $_.DeviceName -like "*Control Vault w/ Fingerprint Touch Sensor*"
}

# Get device model
$DeviceInfo = Get-ComputerInfo -Property CsModel

# Only check on specific model
if ($DeviceInfo.CsModel -eq "Latitude 5440") {
    if ($Driver -and $Driver.DriverVersion) {
        $DriverVersion = [version]$Driver.DriverVersion
        $RequiredVersion = [version]"5.15.20.20"

        if ($DriverVersion -lt $RequiredVersion) {
            Exit 1  # Detection triggered (driver is outdated)
        } else {
            Exit 0  # Detection not triggered (driver is up-to-date)
        }
    } else {
        Exit 1  # Driver not found or missing version
    }
} else {
    Exit 0  # Not applicable device model
}
