function Get-O365OrgMicrosoftEdgeSiteLists {
    <#
    .SYNOPSIS
    Retrieves Microsoft Edge site lists for the organization.

    .DESCRIPTION
    This function retrieves Microsoft Edge site lists for the organization from the specified API endpoint using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365OrgMicrosoftEdgeSiteLists -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/fd/edgeenterprisesitemanagement/api/shard'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}