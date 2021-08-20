function Get-O365BingDataCollection {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/settings/security/bingdatacollection"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}