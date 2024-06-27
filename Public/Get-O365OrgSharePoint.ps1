function Get-O365OrgSharePoint {
    <#
    .SYNOPSIS
    Retrieves SharePoint organization settings.

    .DESCRIPTION
    This function retrieves SharePoint organization settings from the specified URI using the provided headers. It fetches settings such as sharing permissions, site URLs, admin URLs, and collaboration types.

    .PARAMETER Headers
    Authentication token and additional information for the API request. This parameter is required to authenticate the request and provide necessary details for the API call.

    .EXAMPLE
    Get-O365OrgSharePoint -Headers $headers

    .NOTES
    This function retrieves SharePoint organization settings from the specified URI. It is designed to provide a comprehensive overview of the organization's SharePoint settings, including sharing permissions, URLs, and collaboration types. The function uses a translation table to convert numeric collaboration types to their corresponding descriptive names.
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
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/sitessharing"
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
