function Convert-AzureEnterpriseAppsUserConsent {
    [cmdletbinding()]
    param(
        [Array] $PermissionsGrantPoliciesAssigned,
        [switch] $Reverse
    )
    $StringToProcess = $PermissionsGrantPoliciesAssigned[0]

    if (-not $Reverse) {
        $TranslatePermissions = @{
            'ManagePermissionGrantsForSelf.microsoft-user-default-legacy' = 'AllowUserConsentForApps'
            'ManagePermissionGrantsForSelf.microsoft-user-default-low'    = 'AllowUserConsentForSelectedPermissions'
        }
        if ($StringToProcess -and $TranslatePermissions[$StringToProcess]) {
            $TranslatePermissions[$StringToProcess]
        } else {
            'DoNotAllowUserConsent'
        }
    } else {
        $TranslatePermissions = @{
            'AllowUserConsentForApps'                = 'ManagePermissionGrantsForSelf.microsoft-user-default-legacy'
            'AllowUserConsentForSelectedPermissions' = 'ManagePermissionGrantsForSelf.microsoft-user-default-low'
            'DoNotAllowUserConsent'                  = ''
        }
        $TranslatePermissions[$StringToProcess]
    }
}