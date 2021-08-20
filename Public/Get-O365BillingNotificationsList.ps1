
function Get-O365BillingNotificationsList {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/fd/commerceMgmt/mgmtsettings/billingNotificationUsers?api-version=1.0"
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
