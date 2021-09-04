function Set-O365OrgSharing {
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