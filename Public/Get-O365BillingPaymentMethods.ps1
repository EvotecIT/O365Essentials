function Get-O365BillingPaymentMethods {
    <#
    .SYNOPSIS
    Retrieves unsettled charges for payment instruments in the specified organization.

    .DESCRIPTION
    This function retrieves unsettled charges for payment instruments in the organization from the specified API endpoint using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365BillingPaymentMethods -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [string] $ID
    )

    if ($ID) {
        # $Uri = "https://admin.microsoft.com/fd/commerceapi/my-org/paymentInstruments($ID)/unsettledCharges"
        $Uri = "https://admin.microsoft.com/fd/commerceapi/my-org/paymentInstruments($ID)"
    } else {
        $Uri = "https://admin.microsoft.com/fd/commerceapi/my-org/paymentInstruments"
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
