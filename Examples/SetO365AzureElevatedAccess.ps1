Import-Module .\O365Essentials.psd1 -Force

# Connect to your tenant (credentials or device code will be prompted if needed)
$null = Connect-O365Admin -Verbose

# Elevate the permissions of the signed in user
Set-O365AzureElevatedAccess -Verbose

# Or elevate another user directly
# Set-O365AzureElevatedAccess -UserPrincipalName 'another.admin@contoso.com' -Verbose

# Review elevated role assignments for a specific user by UPN
$roles = Get-O365AzureElevatedRoleAssignments -UserPrincipalName 'admin@contoso.com' -Verbose
$roles.value | Format-Table

# Review any deny assignments for the same user
$denies = Get-O365AzureElevatedDenyAssignments -UserPrincipalName 'admin@contoso.com' -Verbose
$denies.value | Format-Table

# Remove the elevated access when finished
Remove-O365AzureElevatedAccess -UserPrincipalName 'admin@contoso.com' -Verbose -WhatIf
