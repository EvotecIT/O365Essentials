function Set-O365SearchIntelligenceMeetingInsights {
    <#
    .SYNOPSIS
    Configures the Meeting Insights feature for Office 365 Search Intelligence.

    .DESCRIPTION
    This function enables or disables Meeting Insights for Office 365 Search Intelligence. Meeting Insights provides users with relevant information about meetings, such as meeting summaries and action items, to enhance their productivity and collaboration.

    .PARAMETER Headers
    A dictionary containing the authorization headers required for the request. This includes tokens and expiration information. You can obtain these headers by using the Connect-O365Admin function.

    .PARAMETER AllowMeetingInsights
    A boolean value indicating whether to enable or disable Meeting Insights. Set to $true to enable or $false to disable.

    .EXAMPLE
    Set-O365SearchIntelligenceMeetingInsights -Headers $headers -AllowMeetingInsights $true
    This example enables Meeting Insights for Office 365 Search Intelligence using the provided headers.

    .EXAMPLE
    Set-O365SearchIntelligenceMeetingInsights -Headers $headers -AllowMeetingInsights $false
    This example disables Meeting Insights for Office 365 Search Intelligence using the provided headers.

    .NOTES
    This function requires a valid connection to Office 365 and the necessary permissions to manage Search Intelligence settings. Ensure you have the appropriate credentials and authorization before running this function.
    #>
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