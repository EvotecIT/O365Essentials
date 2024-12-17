function Set-O365AzureEnterpriseAppsUserConsent {
    <#
    .SYNOPSIS
    Configures user consent settings for Azure enterprise applications.

    .DESCRIPTION
    This function allows administrators to configure user consent settings for Azure enterprise applications.

    .PARAMETER Headers
    Specifies the headers for the API request, typically including authorization tokens.

    .PARAMETER PermissionGrantPoliciesAssigned
    Specifies the permission grant policies assigned for user consent.

    .EXAMPLE
    An example of how to use this function:
    Set-O365AzureEnterpriseAppsUserConsent -Headers $headers -PermissionGrantPoliciesAssigned 'AllowUserConsentForApps'

    .NOTES
    For more information, visit: https://portal.azure.com/#blade/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/UserSettings
    #>
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
