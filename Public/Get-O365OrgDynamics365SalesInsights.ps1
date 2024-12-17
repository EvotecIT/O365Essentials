function Get-O365OrgDynamics365SalesInsights {
    <#
    .SYNOPSIS
    Retrieves Dynamics 365 Sales Insights information for the organization.

    .DESCRIPTION
    This function retrieves Dynamics 365 Sales Insights information for the organization from the specified API endpoint using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365OrgDynamics365SalesInsights -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/admin/api/settings/apps/dci'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
