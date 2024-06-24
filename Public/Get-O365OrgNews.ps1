function Get-O365OrgNews {
    <#
        .SYNOPSIS
        Retrieves news options for Bing in the organization.
        .DESCRIPTION
        This function retrieves news options for Bing in the organization. It can return the content enabled on a new tab and whether company information and industry are enabled.
        .PARAMETER Headers
        Authentication token and additional information created with Connect-O365Admin.
        .PARAMETER NoTranslation
        Indicates whether to skip translation of news options.
        .EXAMPLE
        Get-O365OrgNews -Headers $headers -NoTranslation
        .NOTES
        This function retrieves news options for Bing from the specified URI.
    #>
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
