function Get-O365Sharing {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/settings/security/guestUserPolicy"
    $Output1 = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output1 | Format-Table

    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/sitessharing"
    $Output2 = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output2 | Format-Table

    # $Uri = "https://admin.microsoft.co//admin/api/settings/security/o365guestuser"
    # $Output3 = Invoke-O365Admin -Uri $Uri -Headers $Headers
    # $Output3 | Format-Table

    [PSCustomObject] @{
        AllowGuestAccess                  = $Output1.AllowGuestAccess
        AllowGuestInvitations             = $Output1.AllowGuestInvitations
        SitesSharingEnabled               = $Output1.SitesSharingEnabled
        AllowSharing                      = $Output2.AllowSharing
        SiteUrl                           = $Output2.SiteUrl
        AdminUri                          = $Output2.AdminUri
        RequireAnonymousLinksExpireInDays = $Output2.RequireAnonymousLinksExpireInDays
        CollaborationType                 = $Output2.CollaborationType
    }
}
