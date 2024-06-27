function Get-O365AzureConditionalAccessClassic {
    <#
    .SYNOPSIS
    Retrieves classic Azure Conditional Access policies.

    .DESCRIPTION
    This function retrieves classic Azure Conditional Access policies based on the provided headers.
    It returns information about the classic policies, including their state, users, service principals, controls, and more.

    .PARAMETER Headers
    A dictionary containing the headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365AzureConditionalAccessClassic -Headers $headers

    .NOTES
    For more information, visit: https://docs.microsoft.com/en-us/azure/active-directory/conditional-access/overview
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://main.iam.ad.ext.azure.com/api/ClassicPolicies'

    $QueryParameters = @{
        top      = 10
        nextLink = $null
        filter   = 1
    }

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameters
    if ($Output.items) {
        $Output.items
    }
}