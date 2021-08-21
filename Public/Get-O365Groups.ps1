function Get-O365Groups {
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