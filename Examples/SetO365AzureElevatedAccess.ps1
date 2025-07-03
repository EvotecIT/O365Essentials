Import-Module .\O365Essentials.psd1 -Force

# Connect to your tenant (credentials or device code will be prompted if needed)
$null = Connect-O365Admin -Verbose

# Elevate the permissions of the signed in user
Set-O365AzureElevatedAccess -Verbose

# Or elevate another user directly
# Set-O365AzureElevatedAccess -UserPrincipalName 'another.admin@contoso.com' -Verbose

$roles = Get-O365AzureElevatedRoleAssignments -Verbose
$roles.value | Format-Table
# Or query another user's assignments
# $roles = Get-O365AzureElevatedRoleAssignments -UserPrincipalName 'admin@contoso.com'

$denies = Get-O365AzureElevatedDenyAssignments -Verbose
$denies.value | Format-Table
# Or query deny assignments for another user
# $denies = Get-O365AzureElevatedDenyAssignments -UserPrincipalName 'admin@contoso.com'

# Remove the elevated access when finished
Remove-O365AzureElevatedAccess -Verbose -WhatIf
