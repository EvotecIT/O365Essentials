function Set-O365OrgNews {
    <#
    .SYNOPSIS
    Configures the news settings for an Office 365 organization.

    .DESCRIPTION
    This function allows you to configure the news settings for your Office 365 organization. It sends a PUT request to the Office 365 admin API with the specified settings.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER ContentOnNewTabEnabled
    Specifies whether content on the new tab should be enabled or disabled.

    .PARAMETER CompanyInformationAndIndustryEnabled
    Specifies whether company information and industry news should be shown.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgNews -Headers $headers -ContentOnNewTabEnabled $true -CompanyInformationAndIndustryEnabled $false

    This example enables content on the new tab and disables company information and industry news for the Office 365 organization.
    #>
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
