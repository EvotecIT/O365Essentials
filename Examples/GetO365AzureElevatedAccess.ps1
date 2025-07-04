Import-Module .\O365Essentials.psd1 -Force

# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose

Get-O365AzureElevatedRoleAssignments
#Get-O365AzureElevatedDenyAssignments
#Set-O365AzureElevatedAccess
#Remove-O365AzureElevatedAccess