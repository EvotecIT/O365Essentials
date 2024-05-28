function Set-O365OrgUserConsentApps {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('DoNotAllow', 'AllowLimited', 'AllowAll')]
        [parameter(Mandatory)][string] $UserConsentToApps
    )
    $Uri = "https://graph.microsoft.com/v1.0/policies/authorizationPolicy"

    [Array] $CurrentSettings = Get-O365OrgUserConsentApps -Headers $Headers -Native
    if ($null -eq $CurrentSettings) {
        Write-Warning "No current settings found. Please run Get-O365OrgUserConsentApps first to see what's wrong."
        return
    }

    if ($UserConsentToApps -eq 'DoNotAllow') {
        [Array] $NewSettings = foreach ($Setting in $CurrentSettings) {
            if ($Setting -eq "ManagePermissionGrantsForSelf.microsoft-user-default-low") {

            } elseif ($CurrentSettings -contains "ManagePermissionGrantsForSelf.microsoft-user-default-legacy") {

            } else {
                $Setting
            }
        }
        $Body = @{
            defaultUserRolePermissions = @{
                permissionGrantPoliciesAssigned = @(
                    #"ManagePermissionGrantsForOwnedResource.microsoft-dynamically-managed-permissions-for-chat",
                    #"ManagePermissionGrantsForOwnedResource.microsoft-dynamically-managed-permissions-for-team"
                    $NewSettings | Sort-Object -Unique
                )
            }
        }
    } elseif ($UserConsentToApps -eq 'AllowLimited') {
        [Array]  $NewSettings = foreach ($Setting in $CurrentSettings) {
            if ($Setting -eq "ManagePermissionGrantsForSelf.microsoft-user-default-low") {
                return
            } elseif ($CurrentSettings -contains "ManagePermissionGrantsForSelf.microsoft-user-default-legacy") {

            } else {
                $Setting
            }
        }
        if ($NewSettings -notcontains "ManagePermissionGrantsForSelf.microsoft-user-default-low") {
            $NewSettings += "ManagePermissionGrantsForSelf.microsoft-user-default-low"
        }

        $Body = @{
            defaultUserRolePermissions = @{
                permissionGrantPoliciesAssigned = @(
                    #"ManagePermissionGrantsForOwnedResource.microsoft-dynamically-managed-permissions-for-chat",
                    #"ManagePermissionGrantsForOwnedResource.microsoft-dynamically-managed-permissions-for-team",
                    #"ManagePermissionGrantsForSelf.microsoft-user-default-low"
                    $NewSettings | Sort-Object -Unique
                )
            }
        }
    } elseif ($UserConsentToApps -eq 'AllowAll') {
        [Array] $NewSettings = foreach ($Setting in $CurrentSettings) {
            if ($Setting -eq "ManagePermissionGrantsForSelf.microsoft-user-default-low") {

            } elseif ($CurrentSettings -contains "ManagePermissionGrantsForSelf.microsoft-user-default-legacy") {
                return
            } else {
                $Setting
            }
        }
        if ($NewSettings -notcontains "ManagePermissionGrantsForSelf.microsoft-user-default-legacy") {
            $NewSettings += "ManagePermissionGrantsForSelf.microsoft-user-default-legacy"
        }
        $Body = @{
            defaultUserRolePermissions = @{
                permissionGrantPoliciesAssigned = @(
                    #"ManagePermissionGrantsForOwnedResource.microsoft-dynamically-managed-permissions-for-chat",
                    #"ManagePermissionGrantsForOwnedResource.microsoft-dynamically-managed-permissions-for-team",
                    #"ManagePermissionGrantsForSelf.microsoft-user-default-legacy"
                    $NewSettings | Sort-Object -Unique
                )
            }
        }
    }

    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PATCH -Body $Body
}