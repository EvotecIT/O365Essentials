function Get-O365BillingInvoices {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/fd/commerceapi/my-org/legacyInvoices(startDate=2021-06-01,endDate=2021-08-20)"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}