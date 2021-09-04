function Get-O365OrgUserConsentApps {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/IntegratedApps"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($null -ne $Output) {
        [PSCustomObject] @{
            UserConsentToAppsEnabled = $Output
        }
    }
}