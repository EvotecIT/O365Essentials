function Get-O365OrgBingDataCollection {
    <#
        .SYNOPSIS
        Retrieves the Bing Data Collection settings for the organization.
        .DESCRIPTION
        This function queries the Microsoft Graph API to retrieve the Bing Data Collection settings for the organization.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .EXAMPLE
        Get-O365OrgBingDataCollection -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/settings/security/bingdatacollection"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
