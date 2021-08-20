function Get-O365ConsiergeAll {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/api/concierge/GetConciergeConfigAll"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}