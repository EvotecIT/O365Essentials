function Get-O365OrgOfficeOnTheWeb {
    <#
    .SYNOPSIS
    Retrieves settings for Office Online apps in the organization.

    .DESCRIPTION
    This function retrieves settings for Office Online apps in the organization from the specified URI.

    .PARAMETER Headers
    Authentication token and additional information created with Connect-O365Admin.

    .EXAMPLE
    Get-O365OrgOfficeOnTheWeb -Headers $headers

    .NOTES
    This function retrieves settings for Office Online apps from the specified URI.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/officeonline"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
