function Get-O365OrgBookings {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/bookings"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}