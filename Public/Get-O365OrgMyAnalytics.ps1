function Get-O365OrgMyAnalytics {
    <#
        .SYNOPSIS
        Retrieves MyAnalytics settings for Office 365.
        .DESCRIPTION
        This function retrieves MyAnalytics settings for Office 365 from the specified API endpoint using the provided headers.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .EXAMPLE
        Get-O365OrgMyAnalytics -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/myanalytics"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        [PSCustomObject] @{
            EnableInsightsDashboard    = -not $Output.IsDashboardOptedOut
            EnableWeeklyDigest         = -not $Output.IsEmailOptedOut
            EnableInsightsOutlookAddIn = -not $Output.IsAddInOptedOut
            # IsNudgesOptedOut           : False
            # IsWindowsSignalOptedOut    : False
            # MeetingEffectivenessSurvey : Unavailable
        }
    }
}
