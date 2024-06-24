function Set-O365OrgMyAnalytics {
    <#
        .SYNOPSIS
        Configures MyAnalytics settings for an Office 365 organization.
        .DESCRIPTION
        This function allows you to configure the MyAnalytics settings for your Office 365 organization. 
        It sends a POST request to the Office 365 admin API with the specified settings.
        .PARAMETER Headers
        Specifies the headers for the API request. Typically includes authorization tokens.
        .PARAMETER EnableInsightsDashboard
        Specifies whether the Insights Dashboard should be enabled or disabled.
        .PARAMETER EnableWeeklyDigest
        Specifies whether the Weekly Digest emails should be enabled or disabled.
        .PARAMETER EnableInsightsOutlookAddIn
        Specifies whether the Insights Outlook Add-In should be enabled or disabled.
        .EXAMPLE
        $headers = @{Authorization = "Bearer your_token"}
        Set-O365OrgMyAnalytics -Headers $headers -EnableInsightsDashboard $true -EnableWeeklyDigest $false -EnableInsightsOutlookAddIn $true

        This example enables the Insights Dashboard and the Insights Outlook Add-In, and disables the Weekly Digest emails for the Office 365 organization.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $EnableInsightsDashboard,
        [nullable[bool]] $EnableWeeklyDigest,
        [nullable[bool]] $EnableInsightsOutlookAddIn
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/myanalytics"

    $CurrentSettings = Get-O365OrgMyAnalytics -Headers $Headers
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
