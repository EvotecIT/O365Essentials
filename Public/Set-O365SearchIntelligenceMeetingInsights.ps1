function Set-O365SearchIntelligenceMeetingInsights {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [bool] $AllowMeetingInsights
    )
    $Uri = "https://admin.microsoft.com/fd/ssms/api/v1.0/'3srecs'/Collection('meetinginsights')/Settings(Path=':',LogicalId='MeetingInsightsToggle')"

    if ($PSBoundParameters.ContainsKey('AllowMeetingInsights')) {
        $Body = @{
            Payload = $AllowMeetingInsights.ToString().ToLower()
        }
        #"{`"Payload`":`"false`"}"
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body
        $Output
    }
}