function Get-O365OrgUserConsentApps {
    <#
    .SYNOPSIS
    Retrieves organization user consent apps settings.

    .DESCRIPTION
    This function retrieves organization user consent apps settings from the specified URI using the provided headers.

    .PARAMETER Headers
    Authentication token and additional information for the API request.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $Native
    )
    $Uri = "https://graph.microsoft.com/v1.0/policies/authorizationPolicy"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($null -ne $Output) {
        if ($Native) {
            $Output.defaultUserRolePermissions.permissionGrantPoliciesAssigned
        } else {
            if ($Output.defaultUserRolePermissions.permissionGrantPoliciesAssigned -is [Array]) {
                if ($Output.defaultUserRolePermissions.permissionGrantPoliciesAssigned -contains "ManagePermissionGrantsForSelf.microsoft-user-default-low") {
                    [PSCustomObject] @{
                        UserConsentToApps = 'AllowLimited'
                    }
                } elseif ($Output.defaultUserRolePermissions.permissionGrantPoliciesAssigned -contains "ManagePermissionGrantsForSelf.microsoft-user-default-legacy") {
                    [PSCustomObject] @{
                        UserConsentToApps = 'AllowAll'
                    }
                } else {
                    [PSCustomObject] @{
                        UserConsentToApps = 'DoNotAllow'
                    }
                }
            } else {
                Write-Warning "No data found. Please check the connection and try again."
            }
        }
    } else {
        Write-Warning "No data found. Please check the connection and try again."
    }
}
