function Get-O365AzureTenantSKU {
    <#
    .SYNOPSIS
    Retrieves the SKU information for the Office 365 tenant.

    .DESCRIPTION
    This function retrieves the SKU information for the Office 365 tenant using the provided headers. The SKU information includes details about the tenant's subscription and licensing.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365AzureTenantSKU -Headers $headers
    An example of how to retrieve the SKU information for the Office 365 tenant using specified headers.

    .NOTES
    This function is designed to work with the Office 365 API to fetch the SKU information for the tenant. It requires a valid set of headers, including authorization tokens, to authenticate the request.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://main.iam.ad.ext.azure.com/api/TenantSkuInfo'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        $Output
    }
}