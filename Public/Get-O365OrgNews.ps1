function Get-O365OrgNews {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
    $Uri = "https://admin.microsoft.com/admin/api/searchadminapi/news/options/Bing"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($NoTranslation) {
        $Output
    } else {
        If ($Output) {
            [PSCustomObject] @{
                ContentOnNewTabEnabled               = $Output.NewsOptions.EdgeNTPOptions.IsOfficeContentEnabled
                CompanyInformationAndIndustryEnabled = $Output.NewsOptions.EdgeNTPOptions.IsShowCompanyAndIndustry
            }
        }
    }
}