function Set-O365OrgNews {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $ContentOnNewTabEnabled,
        [nullable[bool]] $CompanyInformationAndIndustryEnabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/searchadminapi/news/options"

    $CurrentSettings = Get-O365OrgNews -Headers $Headers -NoTranslation
    if ($CurrentSettings) {
        $Body = [ordered] @{
            ServiceType = 'Bing'
            NewsOptions = $CurrentSettings.NewsOptions
        }
        if ($null -ne $ContentOnNewTabEnabled) {
            $Body.NewsOptions.EdgeNTPOptions.IsOfficeContentEnabled = $ContentOnNewTabEnabled
        }
        if ($null -ne $CompanyInformationAndIndustryEnabled) {
            $Body.NewsOptions.EdgeNTPOptions.IsShowCompanyAndIndustry = $CompanyInformationAndIndustryEnabled
        }
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body
        $Output
    }
}