function Get-O365OrgReleasePreferences {
    <#
        .SYNOPSIS
        Retrieves organization release preferences from the specified endpoint.
        .DESCRIPTION
        This function retrieves organization release preferences from the specified API endpoint using the provided headers.
        .PARAMETER Headers
        Authentication token and additional information for the API request.
        .NOTES
        Invoke-O365Admin function is used to make administrative calls to the Office 365 API. It handles requests for various administrative tasks.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/Settings/company/releasetrack"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
