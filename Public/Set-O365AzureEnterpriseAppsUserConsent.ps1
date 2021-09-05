function Set-O365AzureEnterpriseAppsUserConsent {
    # https://portal.azure.com/#blade/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/UserSettings
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][string][ValidateSet('AllowUserConsentForApps', 'AllowUserConsentForSelectedPermissions', 'DoNotAllowUserConsent')] $PermissionGrantPoliciesAssigned
    )

    $Uri = 'https://graph.microsoft.com/v1.0/policies/authorizationPolicy'

    $Convert = Convert-AzureEnterpriseAppsUserConsent -PermissionsGrantPoliciesAssigned $PermissionGrantPoliciesAssigned -Reverse

    $Body = @{
        defaultUserRolePermissions = [ordered] @{
            permissionGrantPoliciesAssigned = if ($Convert) { , @($Convert) } else { , @() }
        }
    }
    if ($Body) {
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PATCH -Body $Body
    }
}