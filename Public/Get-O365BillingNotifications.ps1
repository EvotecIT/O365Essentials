function Get-O365BillingNotifications {
    <#
    .SYNOPSIS
    Retrieves invoice preference settings for billing notifications in Office 365.

    .DESCRIPTION
    This function retrieves invoice preference settings for billing notifications in Office 365 from the specified API endpoint using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365BillingNotifications -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/fd/commerceMgmt/mgmtsettings/invoicePreference?api-version=1.0 "
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
