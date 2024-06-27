function Get-O365AzurePropertiesSecurity {
    <#
    .SYNOPSIS
    Retrieves the security default status for the Office 365 tenant.

    .DESCRIPTION
    This function retrieves the security default status for the Office 365 tenant using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365AzurePropertiesSecurity -Headers $headers
    An example of how to retrieve the security default status for the Office 365 tenant using specified headers.

    .NOTES
    This function is designed to work with the Office 365 API to fetch the security default status for the tenant. It requires a valid set of headers, including authorization tokens, to authenticate the request.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://main.iam.ad.ext.azure.com/api/SecurityDefaults/GetSecurityDefaultStatus'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        $Output
    }
}