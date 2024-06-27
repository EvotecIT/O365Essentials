function Get-O365OrgHelpdeskInformation {
    <#
    .SYNOPSIS
    Retrieves helpdesk information for the organization.

    .DESCRIPTION
    This function retrieves helpdesk information for the organization from the specified API endpoint using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365OrgHelpdeskInformation -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/Settings/company/helpdesk"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
