function Get-O365CalendarSharing {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/admin/api/settings/apps/calendarsharing'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}