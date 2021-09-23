function Get-O365BillingProfile {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    # But how do I get AccountID ?
    $AccountID = ''
    $Uri = "https://admin.microsoft.com/fd/commerceMgmt/moderncommerce/myroles/BillingGroup?api-version=3.0&accountId=$AccountID"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -Body $Body
    $Output
}