function Get-O365BillingProfile {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/fd/commerceMgmt/moderncommerce/checkaccess/bulk?api-version=3.0"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}