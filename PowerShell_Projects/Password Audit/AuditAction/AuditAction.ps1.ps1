# Assigning the object usernames to the txt file filled with all the users
$usernames = Get-Content -Path "data.csv"
Write-Host "Test: $usernames"
# Making an object that’s the date of when the script is ran, as a boundary to get rid of recent password changes
$audit_date = Get-Date -Date "2025-10-22"
 
#creating empty lists to add removed and existing objects
$removed = @()
$change = @()
 
# A for loop that goes through and reads the txt file line by line and identifying if they exist in AD
$usernames | ForEach-Object {
  $u = Get-ADUser -Filter {SamAccountName -eq $_}
  if ($u -eq $null) {
    $removed += $_
  }
  else {
    $change += $_
    }
}

# A for loop that goes through and reads the txt file line by line and printing it out in a table setting, whilst also setting boundaries
$UsersToChange = $change | ForEach-Object {
  get-aduser -Identity $_ -properties DisplayName, passwordlastset, passwordneverexpires |
 
  # Exclude passwords which have been changed since the audit
  Where-Object {$_.passwordlastset -le $audit_date}
 
} | Sort-Object -property DisplayName
 
# Display the selected features from get-adusers and sorting in name order
$UsersToChange | Select-Object DisplayName, passwordlastset, Passwordneverexpires
 
# Display accounts which have been removed from the text list
Write-Output "`nThese accounts have been removed `n" $removed
$failed = @()
 
# Export list of users to change into a csv
$UsersToChange | Export-CSV 'src/ChangedAccounts.csv'
$UsersToChange | ForEach-Object {
    $user = $_   # capture the AD user object
 
    try {
        Set-ADUser -Identity $user -ChangePasswordAtLogon $true -ErrorAction Stop
        Write-Host "Updated: $($user.SamAccountName)" -ForegroundColor Green
    } catch {
        $failed += $user.SamAccountName
        Write-Host "FAILED: $($user.SamAccountName) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "List of failed additions- investigate: `n $failed."
 
