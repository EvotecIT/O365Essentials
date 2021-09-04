function Get-O365BillingLicenseRequests {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    if ($Headers) {
        $TentantID = $Headers.Tenant
    } else {
        $TentantID = $Script:AuthorizationO365Cache.Tenant
    }
    $Uri = "https://admin.microsoft.com/fd/m365licensing/v1/tenants/$TentantID/self-service-requests"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output.items
}