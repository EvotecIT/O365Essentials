function Get-O365OrgM365Groups {
    <#
    .SYNOPSIS
    Provides information on how guests from outside the organization can collaborate with users in Microsoft 365 Groups.

    .DESCRIPTION
    This function retrieves settings related to guest access in Microsoft 365 Groups.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365OrgM365Groups -Headers $headers

    .NOTES
    This function provides details on guest access settings in Microsoft 365 Groups.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    #$Uri = "https://admin.microsoft.com/admin/api/settings/security/guestUserPolicy"
    #$Output1 = Invoke-O365Admin -Uri $Uri -Headers $Headers

    $Uri = "https://admin.microsoft.com/admin/api/settings/security/o365guestuser"
    $Output2 = Invoke-O365Admin -Uri $Uri -Headers $Headers

    [PSCustomObject] @{
        #AllowGuestAccess      = $Output1.AllowGuestAccess
        #AllowGuestInvitations = $Output1.AllowGuestInvitations
        #SitesSharingEnabled   = $Output1.SitesSharingEnabled
        AllowGuestsAsMembers = $Output2.AllowGuestsAsMembers
        AllowGuestAccess     = $Output2.AllowGuestAccess
    }
}
