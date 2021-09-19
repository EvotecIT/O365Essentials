<# Not sure where I got this from
function Get-O365BillingLicenseAutoClaim {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    if ($Headers) {
        $TentantID = $Headers.Tenant
    } else {
        $TentantID = $Script:AuthorizationO365Cache.Tenant
    }
    $Uri = "https://admin.microsoft.com/fd/m365licensing/v1/tenants/$TentantID/licenseddevicesassets"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output.items
}
#>
function Get-O365BillingLicenseAutoClaim {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/fd/m365licensing/v1/policies/autoclaim"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}