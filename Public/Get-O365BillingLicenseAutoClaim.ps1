function Get-O365BillingLicenseAutoClaim {
    <#
    .SYNOPSIS
    Retrieves information about licensed devices assets for a specific Office 365 tenant.

    .DESCRIPTION
    This function retrieves information about licensed devices assets for a specific Office 365 tenant using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365BillingLicenseAutoClaim -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/fd/m365licensing/v1/policies/autoclaim"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
