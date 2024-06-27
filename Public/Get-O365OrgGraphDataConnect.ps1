function Get-O365OrgGraphDataConnect {
    <#
    .SYNOPSIS
    Retrieves Graph Data Connect information for the organization.

    .DESCRIPTION
    This function retrieves Graph Data Connect information for the organization from the specified API endpoint using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365OrgGraphDataConnect -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/o365dataplan"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
