function Get-O365AzureConditionalAccessLocation {
    <#
    .SYNOPSIS
    Retrieves Azure Conditional Access Locations.

    .DESCRIPTION
    This function retrieves Azure Conditional Access Locations based on the provided headers.
    It returns information about the named locations defined for Azure Conditional Access policies.

    .PARAMETER Headers
    A dictionary containing the headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365AzureConditionalAccessLocation -Headers $headers

    .NOTES
    For more information, visit: https://docs.microsoft.com/en-us/azure/active-directory/conditional-access/overview
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://graph.microsoft.com/beta/conditionalAccess/namedLocations'

    #?`$filter=&`$orderby=displayName&`$skip=0&`$top=10&`$count=true

    $QueryParameters = @{
        top     = 10
        skip    = 0
        orderby = 'displayName'
        filter  = ''
        count   = 'true'
    }

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameters
    if ($Output) {
        $Output
    }
}