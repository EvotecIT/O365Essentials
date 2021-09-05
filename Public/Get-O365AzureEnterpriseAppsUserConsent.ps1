function Get-O365AzureEnterpriseAppsUserConsent {
    # https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/configure-user-consent?tabs=azure-portal
    # https://portal.azure.com/#blade/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/UserSettings
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )

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