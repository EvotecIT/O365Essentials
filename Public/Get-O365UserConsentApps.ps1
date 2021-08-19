function Get-O365UserConsentApps {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/IntegratedApps"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}