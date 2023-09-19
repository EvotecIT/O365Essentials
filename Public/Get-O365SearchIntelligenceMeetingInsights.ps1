function Get-O365SearchIntelligenceMeetingInsights {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/fd/ssms/api/v1.0/'3srecs'/Collection('meetinginsights')/Settings(Path=':',LogicalId='MeetingInsightsToggle')"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        [PSCustomObject] @{
            AllowMeetingInsights = $Output.Payload -eq 'true'
        }
    }
}