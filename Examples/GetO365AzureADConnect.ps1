Import-Module .\O365Essentials.psd1 -Force

# This makes a connection to Office 365 tenant, using credentials
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose

Get-O365AzureADConnect -Verbose | Format-List
Get-O365AzureADConnectSSO -Verbose | Format-Table

$PTA = Get-O365AzureADConnectPTA -Verbose
$PTA | Format-List
$PTA.Members | Format-Table