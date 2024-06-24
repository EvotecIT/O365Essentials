function Get-O365OrgForms {
    <#
        .SYNOPSIS
        Retrieves information about Office Forms for the organization.
        .DESCRIPTION
        This function retrieves information about Office Forms for the organization from the specified API endpoint using the provided headers.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .EXAMPLE
        Get-O365OrgForms -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/admin/api/settings/apps/officeforms/'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
