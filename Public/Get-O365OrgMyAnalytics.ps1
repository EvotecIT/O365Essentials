function Get-O365OrgMyAnalytics {
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