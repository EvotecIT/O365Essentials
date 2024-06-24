function Set-O365OrgCalendarSharing {
    <#
    .SYNOPSIS
    Let your users share their calendars with people outside of your organization who have Office 365 or Exchange

    .DESCRIPTION
    Let your users share their calendars with people outside of your organization who have Office 365 or Exchange

    .PARAMETER Headers
    Authentication Token along with additional information that is created with Connect-O365Admin. If heaaders are not provided it will use the default token.

    .PARAMETER EnableAnonymousCalendarSharing
    Enables or Disables anonymous calendar sharing

    .PARAMETER EnableCalendarSharing
    Enables or Disables calendar sharing

    .PARAMETER SharingOption
    Decide on how to share the calendar
    - Show calendar free/busy information with time only (CalendarSharingFreeBusySimple)
    - Show calendar free/busy information with time, subject and location (CalendarSharingFreeBusyDetail)
    - Show all calendar appointment information (CalendarSharingFreeBusyReviewer)

    .EXAMPLE
    Set-O365CalendarSharing -EnableCalendarSharing $false

    .NOTES
    General notes
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $EnableAnonymousCalendarSharing,
        [nullable[bool]] $EnableCalendarSharing,
        [string][ValidateSet('CalendarSharingFreeBusyDetail', 'CalendarSharingFreeBusySimple', 'CalendarSharingFreeBusyReviewer')] $SharingOption
    )
    # We need to get current settings because it always requires all parameters
    # If we would just provide one parameter it would reset everything else
    $CurrentSettings = Get-O365OrgCalendarSharing -Headers $Headers
    $Body = [ordered] @{
        ContractIdentity               = $CurrentSettings.ContractIdentity
        EnableAnonymousCalendarSharing = $CurrentSettings.EnableAnonymousCalendarSharing
        EnableCalendarSharing          = $CurrentSettings.EnableCalendarSharing
        SharingOption                  = $CurrentSettings.SharingOption
    }
    if ($null -ne $EnableAnonymousCalendarSharing) {
        $Body.EnableAnonymousCalendarSharing = $EnableAnonymousCalendarSharing
    }
    if ($null -ne $EnableCalendarSharing) {
        $Body.EnableCalendarSharing = $EnableCalendarSharing
    }
    if ($SharingOption) {
        $Body.SharingOption = $SharingOption
    }
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/calendarsharing"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}
