function Get-O365AzureConditionalAccessTerms {
    <#
    .SYNOPSIS
    Retrieves Azure Conditional Access Terms.

    .DESCRIPTION
    This function retrieves Azure Conditional Access Terms based on the provided headers.
    It returns information about the terms of use agreements for Azure Conditional Access.

    .PARAMETER Headers
    A dictionary containing the headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365AzureConditionalAccessTerms -Headers $headers

    .NOTES
    For more information, visit: https://docs.microsoft.com/en-us/azure/active-directory/conditional-access/overview
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    # ?`$orderby=Name%20asc&`$filter=TypeId%20eq%208a76863a-a0e6-47a7-b99e-0410266eebcf
    # &x-tenantid=ceb371f6-8745-4876-a040-69f2d10a9d1a&{}&_=1631363067293
    $Uri = 'https://api.termsofuse.identitygovernance.azure.com/v1.1/Agreements'

    $QueryParameter = @{
        '$orderby'   = 'Name asc'
        '$filter'    = 'TypeId eq 8a76863a-a0e6-47a7-b99e-0410266eebcf'
        'x-tenantid' = $TenantID
    }

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        $Output
    }
}