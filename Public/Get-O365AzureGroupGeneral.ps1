function Get-O365AzureGroupGeneral {
    <#
    .SYNOPSIS
    Get settings for Azure Groups General Tab

    .DESCRIPTION
    Get settings for Azure Groups General Tab

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

    .EXAMPLE
    Get-O365AzureGroupGeneral -Verbose

    .NOTES
    https://portal.azure.com/#blade/Microsoft_AAD_IAM/GroupsManagementMenuBlade/General
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $SGGM = Get-O365AzureGroupSelfService -Headers $Headers
    if ($SGGM) {
        $OutputInformation = [ordered] @{}
        # weird thing is that changing this userDelegationEnabled which is not available on SGGM changes selfServiceGroupManagementEnabled
        $OutputInformation['OwnersCanManageGroupMembershipRequests'] = $SGGM.selfServiceGroupManagementEnabled
        $OutputInformation['SelfServiceRestrictUserAbilityAccessGroups'] = -not $SGGM.groupsInAccessPanelEnabled
        $OutputInformation['AllowedToCreateSecurityGroups'] = (Get-O365AzureGroupSecurity -Headers $Headers).AllowedToCreateSecurityGroups
        $OutputInformation['AllowedToCreateM365Groups'] = (Get-O365AzureGroupM365 -Headers $Headers).EnableGroupCreation
        [PSCustomObject] $OutputInformation
    }
}