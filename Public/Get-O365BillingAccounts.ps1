function Get-O365BillingAccounts {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/fd/jarvisCM/my-org/profiles?type=organization"
    $Uri = "https://admin.microsoft.com/fd/commerceMgmt/billingaccount"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}