function Get-O365AzureEnterpriseAppsUserConsent {
    <#
    .SYNOPSIS
    Retrieves user consent settings for Azure Enterprise Apps.

    .DESCRIPTION
    This function retrieves user consent settings for Azure Enterprise Apps based on the provided headers.
    It returns information about permissions and policies assigned to users.

    .PARAMETER Headers
    A dictionary containing the headers for the API request, typically including authorization information.

    .PARAMETER NoTranslation
    Specifies whether to return the consent settings without translation.

    .EXAMPLE
    Get-O365AzureEnterpriseAppsUserConsent -Headers $headers

    .NOTES
    For more information, visit: https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/configure-user-consent?tabs=azure-portal
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
    # https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/configure-user-consent?tabs=azure-portal
    # https://portal.azure.com/#blade/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/UserSettings

    $Uri = 'https://graph.microsoft.com/v1.0/policies/authorizationPolicy?$select=defaultUserRolePermissions'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        if ($NoTranslation) {
            $Output
        } else {
            [PSCustomObject] @{
                allowedToCreateApps             = $Output.defaultUserRolePermissions.allowedToCreateApps
                allowedToCreateSecurityGroups   = $Output.defaultUserRolePermissions.allowedToCreateSecurityGroups
                allowedToReadOtherUsers         = $Output.defaultUserRolePermissions.allowedToReadOtherUsers
                permissionGrantPoliciesAssigned = Convert-AzureEnterpriseAppsUserConsent -PermissionsGrantPoliciesAssigned $Output.defaultUserRolePermissions.permissionGrantPoliciesAssigned
            }
        }
    }
}
