function Set-O365MyAnalytics {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $EnableInsightsDashboard,
        [nullable[bool]] $EnableWeeklyDigest,
        [nullable[bool]] $EnableInsightsOutlookAddIn
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/myanalytics"

    $CurrentSettings = Get-O365MyAnalytics -Headers $Headers
    if ($CurrentSettings) {
        $Body = @{
            value = @{
                IsDashboardOptedOut = $CurrentSettings.EnableInsightsDashboard
                IsEmailOptedOut     = $CurrentSettings.EnableWeeklyDigest
                IsAddInOptedOut     = $CurrentSettings.EnableInsightsOutlookAddIn
            }
        }
        if ($null -ne $EnableInsightsDashboard) {
            $Body.value.IsDashboardOptedOut = -not $EnableInsightsDashboard
        }
        if ($null -ne $EnableWeeklyDigest) {
            $Body.value.IsEmailOptedOut = -not $EnableWeeklyDigest
        }
        if ($null -ne $EnableInsightsOutlookAddIn) {
            $Body.value.IsAddInOptedOut = -not $EnableInsightsOutlookAddIn
        }
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
        $Output
    }
}