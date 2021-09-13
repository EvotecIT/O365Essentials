Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365AzureGroupGeneral -Verbose

Get-O365AzureGroupSecurity -Verbose
Set-O365AzureGroupSecurity -Verbose -AllowedToCreateSecurityGroups $true -WhatIf

Get-O365AzureGroupM365 -Verbose
Set-O365AzureGroupM365 -Verbose -AllowedToCreateM365Groups $true -WhatIf

Get-O365AzureGroupSelfService -Verbose
Set-O365AzureGroupSelfService -Verbose -RestrictUserAbilityToAccessGroupsFeatures $true -OwnersCanManageGroupMembershipRequests $true -WhatIf