function Get-O365BillingPaymentMethods {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/fd/commerceapi/my-org/paymentInstruments('ObnETQAAAAABAACA')/unsettledCharges"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}