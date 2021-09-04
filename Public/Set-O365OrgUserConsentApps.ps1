function Set-O365OrgUserConsentApps {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][bool] $UserConsentToAppsEnabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/IntegratedApps"

    $Body = @{
        Enabled = $UserConsentToAppsEnabled
    }
    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
}