function Get-O365BillingLicenseRequests {
    <#
    .SYNOPSIS
    Retrieves self-service license requests for a specific Office 365 tenant.

    .DESCRIPTION
    This function retrieves self-service license requests for a specific Office 365 tenant using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365BillingLicenseRequests -Headers $headers
    #>
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
