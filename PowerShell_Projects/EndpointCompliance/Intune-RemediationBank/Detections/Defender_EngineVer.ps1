$MinimumAMEngineVersion = '1.1.26020.3'

$AMEngineVersion = Get-MpComputerStatus | Select-Object -ExpandProperty AMEngineVersion
if ([version]$AMEngineVersion -ge [version]$MinimumAMEngineVersion) {
    exit 0
}    
exit 1



