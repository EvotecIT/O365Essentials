Import-Module .\O365Essentials.psd1 -Force

# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose

$LicenseGroup = Get-O365GroupLicenses -GroupID '75233998-a950-41de-97d0-6c259d0580a7' -Verbose
$LicenseGroup | Format-Table

$LicenseGroup = Get-O365GroupLicenses -GroupName 'Test-Group-TestEVOTECPL' -Verbose
$LicenseGroup | Format-Table