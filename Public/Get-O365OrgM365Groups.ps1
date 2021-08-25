function Get-O365OrgM365Groups {
    <#
    .SYNOPSIS
    Choose how guests from outside your organization can collaborate with your users in Microsoft 365 Groups. Learn more about guest access to Microsoft 365 Groups
    .DESCRIPTION
    Long description

    .PARAMETER Headers
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    #$Uri = "https://admin.microsoft.com/admin/api/settings/security/guestUserPolicy"
    #$Output1 = Invoke-O365Admin -Uri $Uri -Headers $Headers

    $Uri = "https://admin.microsoft.com/admin/api/settings/security/o365guestuser"
    $Output2 = Invoke-O365Admin -Uri $Uri -Headers $Headers

    [PSCustomObject] @{
        #AllowGuestAccess      = $Output1.AllowGuestAccess
        #AllowGuestInvitations = $Output1.AllowGuestInvitations
        #SitesSharingEnabled   = $Output1.SitesSharingEnabled
        AllowGuestsAsMembers = $Output2.AllowGuestsAsMembers
        AllowGuestAccess     = $Output2.AllowGuestAccess
    }
}