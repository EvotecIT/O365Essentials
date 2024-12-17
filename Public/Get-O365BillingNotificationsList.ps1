function Get-O365BillingNotificationsList {
    <#
    .SYNOPSIS
    Retrieves a list of billing notification users in Office 365.

    .DESCRIPTION
    This function retrieves a list of billing notification users in Office 365 from the specified API endpoint using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365BillingNotificationsList -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/fd/commerceMgmt/mgmtsettings/billingNotificationUsers?api-version=1.0"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}

<# Not working
function Get-O365BillingNotificationsList {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/Users/ListBillingNotificationsUsers"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST
    $Output
}

Get-O365BillingNotificationsList
#>
