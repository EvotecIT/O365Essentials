function Set-O365AzureGroupSelfService {
    <#
    .SYNOPSIS
    Set settings for Self Service Group Management - "Owners can manage group membership requests in the Access Panel"

    .DESCRIPTION
    Set settings for Self Service Group Management - "Owners can manage group membership requests in the Access Panel"

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

    .PARAMETER OwnersCanManageGroupMembershipRequests
    Enables or disable Self Service Group Management - "Owners can manage group membership requests in the Access Panel"

    .PARAMETER RestrictUserAbilityToAccessGroupsFeatures
    Enables or disables Self Service Group Management - "Restrict user ability to access groups features in the Access Panel. Group and User Admin will have read-only access when the value of this setting is 'Yes'."

    .EXAMPLE
    Set-O365AzureGroupSelfService -Verbose -OwnersCanManageGroupMembershipRequests $true -WhatIf

    .NOTES
    https://portal.azure.com/#blade/Microsoft_AAD_IAM/GroupsManagementMenuBlade/General
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter()][bool] $OwnersCanManageGroupMembershipRequests,
        [parameter()][bool] $RestrictUserAbilityToAccessGroupsFeatures
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/Directories/SsgmProperties/"

    $Body = @{}
    if ($PSBoundParameters.ContainsKey("OwnersCanManageGroupMembershipRequests")) {
        $Body['userDelegationEnabled'] = $OwnersCanManageGroupMembershipRequests
        # It seems that to enable selfServiceGroupManagement one needs to enable userDelegationEnabled which cannot be read
        # from the same URL as the other properties, but selfServiceGroupManagement seems to be the value we need
        #$Body['selfServiceGroupManagementEnabled'] = $OwnersCanManageGroupMembershipRequests
    }
    if ($PSBoundParameters.ContainsKey("RestrictUserAbilityToAccessGroupsFeatures")) {
        $Body['groupsInAccessPanelEnabled'] = -not $RestrictUserAbilityToAccessGroupsFeatures
    }

    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body

}