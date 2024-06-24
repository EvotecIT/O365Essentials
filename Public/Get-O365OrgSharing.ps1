function Get-O365OrgSharing {
    <#
    .SYNOPSIS
    Retrieves organization sharing settings.

    .DESCRIPTION
    This function retrieves organization sharing settings from the specified URI using the provided headers.

    .PARAMETER Headers
    Authentication token and additional information for the API request.

    .PARAMETER NoTranslation
    Switch to bypass translation.

    .EXAMPLE
    Get-O365OrgSharing -Headers $headers

    .NOTES
    This function retrieves organization sharing settings from the specified URI.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )

    $Uri = "https://admin.microsoft.com/admin/api/settings/security/guestUserPolicy"
    $Output1 = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($NoTranslation) {
        $Output1
    } else {
        # In fiddler we coudld see additional queries, but in edge/chrome not so much
        #$Uri = "https://admin.microsoft.com/admin/api/settings/apps/sitessharing"
        #$Output2 = Invoke-O365Admin -Uri $Uri -Headers $Headers
        #$Output2 | Format-Table

        # $Uri = "https://admin.microsoft.co//admin/api/settings/security/o365guestuser"
        # $Output3 = Invoke-O365Admin -Uri $Uri -Headers $Headers
        # $Output3 | Format-Table
        if ($Output1) {
            [PSCustomObject] @{
                # GUI doesn't show them, so mayne lets not show them eiter
                #AllowGuestAccess                  = $Output1.AllowGuestAccess
                LetUsersAddNewGuests = $Output1.AllowGuestInvitations
                #SitesSharingEnabled               = $Output1.SitesSharingEnabled
                #AllowSharing                      = $Output2.AllowSharing
                #SiteUrl                           = $Output2.SiteUrl
                #AdminUri                          = $Output2.AdminUri
                #RequireAnonymousLinksExpireInDays = $Output2.RequireAnonymousLinksExpireInDays
                #CollaborationType                 = $Output2.CollaborationType
            }
        }
    }
}
