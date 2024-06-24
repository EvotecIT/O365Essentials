function Set-O365OrgSharing {
    <#
    .SYNOPSIS
    Configures the guest user policy for an Office 365 organization.

    .DESCRIPTION
    This function updates the guest user policy settings for an Office 365 organization. It allows enabling or disabling the ability for users to add new guests.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER LetUsersAddNewGuests
    Specifies whether users are allowed to add new guests. Set to $true to allow, $false to disallow.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgSharing -Headers $headers -LetUsersAddNewGuests $true

    This example allows users to add new guests in the Office 365 organization.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][bool] $LetUsersAddNewGuests
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/security/guestUserPolicy"
    $Body = @{
        AllowGuestInvitations = $LetUsersAddNewGuests
    }
    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
}
