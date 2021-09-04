function Get-O365OrgNews {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    <#
    $Uri = "https://admin.microsoft.com/admin/api/searchadminapi/news"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output



    $Uri = "https://admin.microsoft.com/admin/api/searchadminapi/news/options/Bing"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output

    $Uri = "https://admin.microsoft.com/admin/api/searchadminapi/news/industry/Bing"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output

    $Uri = "https://admin.microsoft.com/admin/api/searchadminapi/news/msbenabled/Bing"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
    #>

    $Uri = "https://admin.microsoft.com/admin/api/searchadminapi/news/options"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output

    # WARNING: Invoke-O365Admin - Error JSON: Response status code does not indicate success: 400 (Bad Request). An API version is required, but was not specified.
}