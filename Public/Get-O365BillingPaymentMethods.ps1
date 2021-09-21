function Get-O365BillingPaymentMethods {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [string] $ID
    )

    if ($ID) {
        # $Uri = "https://admin.microsoft.com/fd/commerceapi/my-org/paymentInstruments($ID)/unsettledCharges"
        $Uri = "https://admin.microsoft.com/fd/commerceapi/my-org/paymentInstruments($ID)"
    } else {
        $Uri = "https://admin.microsoft.com/fd/commerceapi/my-org/paymentInstruments"
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}