function Set-O365AzureExternalCollaborationSettings {
    <#
    .SYNOPSIS
    Configures external collaboration settings for Office 365 Azure.

    .DESCRIPTION
    This function allows administrators to configure various settings related to external collaboration in Office 365 Azure. It includes options for managing invitations, subscription sign-ups, self-service password reset (SSPR), and more.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER AllowInvitesFrom
    Specifies who can send invitations to external users. Valid values are 'none', 'adminsAndGuestInviters', 'adminsGuestInvitersAndAllMembers', 'everyone'.

    .PARAMETER AllowedToSignUpEmailBasedSubscriptions
    Indicates whether users are allowed to sign up for email-based subscriptions.

    .PARAMETER AllowedToUseSSPR
    Indicates whether users are allowed to use Self-Service Password Reset.

    .PARAMETER AllowEmailVerifiedUsersToJoinOrganization
    Indicates whether email verified users are allowed to join the organization.

    .PARAMETER BlockMsolPowerShell
    Indicates whether to block the use of MSOnline PowerShell module.

    .PARAMETER DisplayName
    The display name for the settings.

    .PARAMETER Description
    A description of the settings.

    .PARAMETER GuestUserRole
    Specifies the role of a guest user. Valid values are 'User', 'GuestUser', 'RestrictedUser'.

    .PARAMETER AllowedToCreateApps
    Indicates whether users are allowed to create applications.

    .PARAMETER AllowedToCreateSecurityGroups
    Indicates whether users are allowed to create security groups.

    .PARAMETER AllowedToReadOtherUsers
    Indicates whether users are allowed to read other users' profiles.

    .PARAMETER PermissionGrantPoliciesAssigned
    Specifies the permission grant policies assigned to the user.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365AzureExternalCollaborationSettings -Headers $headers -AllowInvitesFrom "everyone" -AllowedToSignUpEmailBasedSubscriptions $true -AllowedToUseSSPR $true -AllowEmailVerifiedUsersToJoinOrganization $false -BlockMsolPowerShell $false -DisplayName "External Collaboration Policy" -Description "Policy for managing external collaboration." -GuestUserRole "GuestUser" -AllowedToCreateApps $true -AllowedToCreateSecurityGroups $true -AllowedToReadOtherUsers $false -PermissionGrantPoliciesAssigned @("Policy1", "Policy2")

    .NOTES
    Ensure that you have the necessary permissions to invoke this command.
    #>
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
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PATCH -Body $Body
        #$Output
    }
}
