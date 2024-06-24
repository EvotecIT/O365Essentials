function Get-O365OrgSharePoint {
    <#
    .SYNOPSIS
    Retrieves SharePoint organization settings.

    .DESCRIPTION
    This function retrieves SharePoint organization settings from the specified URI using the provided headers.

    .PARAMETER Headers
    Authentication token and additional information for the API request.

    .EXAMPLE
    Get-O365OrgSharePoint -Headers $headers

    .NOTES
    This function retrieves SharePoint organization settings from the specified URI.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $TranslateCollaboration = @{
        '2'  = 'NewAndExistingGuestsOnly'
        '16' = 'Anyone'
        '32' = 'ExistingGuestsOnly'
        '1'  = 'OnlyPeopleInYourOrganization'
    }
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/sitessharing"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        [PSCustomObject] @{
            AllowSharing                      = $Output.AllowSharing
            SiteUrl                           = $Output.SiteUrl
            AdminUrl                          = $Output.AdminUrl
            RequireAnonymousLinksExpireInDays = $Output.RequireAnonymousLinksExpireInDays
            CollaborationType                 = $TranslateCollaboration[$Output.CollaborationType.ToString()]
        }
    }
}
