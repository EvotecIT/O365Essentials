Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant, using credentials
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

<#
Get-O365AzureADRoles | Format-Table
Get-O365AzureADRolesMember -RoleName 'Global Administrator', 'Global Reader', 'Service Support Administrator' | Format-Table
Get-O365AzureADRolesMember -RoleName 'Global Reader' | Format-Table
Get-O365AzureADRolesMember -RoleName 'Global Administrator' | Format-Table
#>
#Get-O365AzureADRolesMember -All -Verbose | Format-Table

$Roles = Get-O365AzureADRolesMember -RoleName 'Global Administrator', 'Directory readers', 'Security Reader'
$Roles.'Directory readers'