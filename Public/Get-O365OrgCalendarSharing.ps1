function Get-O365OrgCalendarSharing {
    <#
        .SYNOPSIS
        Let your users share their calendars with people outside of your organization who have Office 365 or Exchange
        .DESCRIPTION
        Let your users share their calendars with people outside of your organization who have Office 365 or Exchange
        .PARAMETER Headers
        Authentication Token along with additional information that is created with Connect-O365Admin. If heaaders are not provided it will use the default token.
        .EXAMPLE
        Get-O365CalendarSharing
        .NOTES
        General notes
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/admin/api/settings/apps/calendarsharing'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
