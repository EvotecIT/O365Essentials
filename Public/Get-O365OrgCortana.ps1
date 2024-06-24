function Get-O365OrgCortana {
    <#
    .SYNOPSIS
    Retrieves Cortana app information for the organization.

    .DESCRIPTION
    This function retrieves Cortana app information for the organization from the specified API endpoint using the provided headers.

    .PARAMETER Headers
    Specifies the headers containing the authorization information.

    .EXAMPLE
    Get-O365OrgCortana -Headers $Headers
    An example of how to retrieve Cortana app information.

    .NOTES
    General notes
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/admin/api/services/apps/cortana'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
