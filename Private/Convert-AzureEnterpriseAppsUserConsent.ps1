function Convert-AzureEnterpriseAppsUserConsent {
    <#
        .SYNOPSIS
        Converts Azure Enterprise Apps user consent policies between internal and external representations.

        .DESCRIPTION
        This function translates Azure Enterprise Apps user consent policies from their internal representation to a more user-friendly format and vice versa. 
        It can be used to convert policies for display or for processing by other functions.
        
        .PARAMETER PermissionsGrantPoliciesAssigned
        An array of policies assigned to the user. The function processes the first element of this array.
        
        .PARAMETER Reverse
        A switch parameter. If specified, the function performs the reverse translation, converting user-friendly policy names back to their internal representations.
        
        .EXAMPLE
        Convert-AzureEnterpriseAppsUserConsent -PermissionsGrantPoliciesAssigned @('ManagePermissionGrantsForSelf.microsoft-user-default-legacy')
        This example converts the internal policy 'ManagePermissionGrantsForSelf.microsoft-user-default-legacy' to 'AllowUserConsentForApps'.
        
        .EXAMPLE
        Convert-AzureEnterpriseAppsUserConsent -PermissionsGrantPoliciesAssigned @('AllowUserConsentForApps') -Reverse
        This example converts the user-friendly policy 'AllowUserConsentForApps' back to its internal representation 'ManagePermissionGrantsForSelf.microsoft-user-default-legacy'.
        
        .NOTES
        This function only processes the first element of the PermissionsGrantPoliciesAssigned array.
    #>
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
