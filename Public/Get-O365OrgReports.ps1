function Get-O365OrgReports {
    <#
    .SYNOPSIS
    Retrieves organization reports configuration.

    .DESCRIPTION
    This function retrieves the organization's reports configuration from the specified URI using the provided headers.

    .PARAMETER Headers
    Authentication token and additional information for the API request.

    .EXAMPLE
    Get-O365OrgReports -Headers $headers

    .NOTES
    This function retrieves organization reports configuration from the specified URI.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/reports/config/GetTenantConfiguration"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $OutputFromJson = $Output.Output | ConvertFrom-Json
    $OutputFromJson
}
