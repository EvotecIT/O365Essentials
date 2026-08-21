function Get-O365BillingAccounts {
    <#
    .SYNOPSIS
    Retrieves billing accounts information from Office 365.

    .DESCRIPTION
    Lists the billing accounts the signed-in user can access through the documented
    Microsoft.Billing Azure Resource Manager API. The connection must include the
    ARM authorization context returned by Connect-O365Admin.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365BillingAccounts -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://management.azure.com/providers/Microsoft.Billing/billingAccounts'
    $QueryParameter = @{
        'api-version' = '2024-04-01'
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -QueryParameter $QueryParameter -ErrorAction Stop
    $Output
}
