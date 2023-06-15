# Get all users
$users = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName

# Display users in a grid view and allow selection
$username = $users | Out-GridView -Title 'Please select a user' -OutputMode Single

# Set variables to indicate value and key to set
$usercid = (New-Object System.Security.Principal.NTAccount($username)).Translate([System.Security.Principal.SecurityIdentifier]).Value
#Write-Host "User CID is: $usercid"
$registryPath = "REGISTRY::HKEY_USERS\$usercid\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$valueName    = "NoControlPanel"

# Create the key if it does not exist
If (-NOT (Test-Path $registryPath)) {
  New-Item -Path $registryPath -Force
  New-ItemProperty -Path $registryPath -Name $valueName -Value 0 -PropertyType DWORD -Force
}  

# Check if the path exists
if(Test-Path $registryPath) {
    # Read the value
    $value = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue

    # Check if the value exists
    if($null -ne $value) {
        # Toggle the value
        if($value.$valueName -eq 0) {
            Set-ItemProperty -Path $registryPath -Name $valueName -Value 1
            Write-Host "Control Panel DISABLED for $username”
        } else {
            Set-ItemProperty -Path $registryPath -Name $valueName -Value 0
            Write-Host "Control Panel ENABLED for $username”
        }
    } else {
        Write-Host "Value does not exist"
    }
} else {
    Write-Host "Path does not exist"
}
