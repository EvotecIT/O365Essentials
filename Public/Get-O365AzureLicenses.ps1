function Get-O365AzureLicenses {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/AccountSkus?backfillTenants=false"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
