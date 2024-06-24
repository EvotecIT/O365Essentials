function Get-O365SearchIntelligenceMeetingInsights {
    <#
        .SYNOPSIS
        Retrieves meeting insights for Office 365 search intelligence.
        .DESCRIPTION
        This function retrieves meeting insights for Office 365 search intelligence from the specified API endpoint using the provided headers.
        .PARAMETER Headers
        Authentication token and additional information for the API request.
    #>
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
