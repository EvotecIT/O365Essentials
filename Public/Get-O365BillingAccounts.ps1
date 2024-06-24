function Get-O365BillingAccounts {
    <#
    .SYNOPSIS
    Retrieves billing accounts information from Office 365.

    .DESCRIPTION
    This function retrieves billing accounts information from Office 365 using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365BillingAccounts -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/fd/jarvisCM/my-org/profiles?type=organization"
    $Uri = "https://admin.microsoft.com/fd/commerceMgmt/billingaccount"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
