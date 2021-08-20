function Get-O365BillingNotifications {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/fd/commerceMgmt/mgmtsettings/invoicePreference?api-version=1.0 "
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}