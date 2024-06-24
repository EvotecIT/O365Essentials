function Get-O365OrgDataLocation {
    <#
    .SYNOPSIS
    Retrieves the data location information for the organization.

    .DESCRIPTION
    This function retrieves the data location information for the organization from the specified API endpoint using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365OrgDataLocation -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/tenant/datalocation"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
