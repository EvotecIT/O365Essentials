function Set-O365AzureExternalCollaborationSettings {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('none', 'adminsAndGuestInviters', 'adminsGuestInvitersAndAllMembers', 'everyone')][string] $AllowInvitesFrom,
        [System.Nullable[bool]] $AllowedToSignUpEmailBasedSubscriptions,
        [System.Nullable[bool]] $AllowedToUseSSPR,
        [System.Nullable[bool]] $AllowEmailVerifiedUsersToJoinOrganization,
        [System.Nullable[bool]] $BlockMsolPowerShell,
        [string] $DisplayName,
        [string] $Description,
        [ValidateSet('User', 'GuestUser', 'RestrictedUser')][string] $GuestUserRole,
        [System.Nullable[bool]] $AllowedToCreateApps,
        [System.Nullable[bool]] $AllowedToCreateSecurityGroups,
        [System.Nullable[bool]] $AllowedToReadOtherUsers,
        [Array] $PermissionGrantPoliciesAssigned
    )

    $GuestUserRoleIDs = @{
        'User'           = 'a0b1b346-4d3e-4e8b-98f8-753987be4970'
        'GuestUser'      = '10dae51f-b6af-4016-8d66-8c2a99b929b3'
        'RestrictedUser' = '2af84b1e-32c8-42b7-82bc-daa82404023b'
    }
    if ($GuestUserRole) {
        $GuestUserRoleID = $GuestUserRoleIDs[$GuestUserRole]
    }

    if ($AllowInvitesFrom) {
        # This translation is to make sure the casing is correct as it may be given by user in different way
        if ($AllowInvitesFrom -eq 'none') {
            $AllowInvitesFrom = 'none'
        } elseif ($AllowInvitesFrom -eq 'adminsAndGuestInviters') {
            $AllowInvitesFrom = 'adminsAndGuestInviters'
        } elseif ($AllowInvitesFrom -eq 'adminsGuestInvitersAndAllMembers') {
            $AllowInvitesFrom = 'adminsGuestInvitersAndAllMembers'
        } elseif ($AllowInvitesFrom -eq 'everyone') {
            $AllowInvitesFrom = 'everyone'
        }
    }

    $Uri = 'https://graph.microsoft.com/v1.0/policies/authorizationPolicy'

    $Body = @{
        allowInvitesFrom                          = $AllowInvitesFrom                          # : adminsAndGuestInviters
        allowedToSignUpEmailBasedSubscriptions    = $AllowedToSignUpEmailBasedSubscriptions    # : True
        allowedToUseSSPR                          = $AllowedToUseSSPR                          # : True
        allowEmailVerifiedUsersToJoinOrganization = $AllowEmailVerifiedUsersToJoinOrganization # : False
        blockMsolPowerShell                       = $BlockMsolPowerShell                       # : False
        displayName                               = $DisplayName                               # : Authorization Policy
        description                               = $Description                               # : Used to manage authorization related settings across the company.
        guestUserRoleId                           = $GuestUserRoleId                           # : a0b1b346-4d3e-4e8b-98f8-753987be4970
        defaultUserRolePermissions                = [ordered] @{
            allowedToCreateApps             = $AllowedToCreateApps
            allowedToCreateSecurityGroups   = $AllowedToCreateSecurityGroups
            allowedToReadOtherUsers         = $AllowedToReadOtherUsers
            permissionGrantPoliciesAssigned = $PermissionGrantPoliciesAssigned
        }
    }
    Remove-EmptyValue -Hashtable $Body -Recursive -Rerun 2
    if ($Body) {
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PATCH -Body $Body
        #$Output
    }
}