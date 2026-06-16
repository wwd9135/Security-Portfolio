# Set all ASR rules to Audit Mode (2 = Audit, 1 = Block, 0 = Off)
$rules = @(
    "BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550",
    "D4F940AB-401B-4EFC-AADC-AD5F3C50688A",
    "3B576869-A4EC-4529-8536-B80A7769E899",
    "75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84",
    "D3E037E1-3EB8-44C8-A917-57927947596D",
    "5BEB7EFE-FD9A-4556-801D-275E5FFC04CC",
    "92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B",
    "01443614-CD74-433A-B99E-2ECDC07BFC25",
    "C1DB55AB-C21A-4637-BB3F-A12568109D35",
    "9E6C4E1F-7D60-472F-BA1A-A39EF669E4B0",
    "D1E49AAC-8F56-4280-B9BA-993A6D77406C",
    "B2B3F03D-6A65-4F7B-A9C7-1C7EF74A9BA4",
    "26190899-1602-49E8-8B27-EB1D0A1CE869",
    "7674BA52-37EB-4A4F-A9A1-F0F9A1619A2C",
    "E6DB77E5-3DF2-4CF1-B95A-636979351E5B"
)

try {
foreach ($rule in $rules) {
    Add-MpPreference -AttackSurfaceReductionRules_Ids $rule `
                     -AttackSurfaceReductionRules_Actions AuditMode
} write-host "success"} catch{
} Write-Host $ERROR


# Test using the following command to verify that the ASR rules are set to Audit Mode:
$test = Get-MpPreference | Select-Object -ExpandProperty AttackSurfaceReductionRules_Actions
write-host "ASR Rules set to: $test"