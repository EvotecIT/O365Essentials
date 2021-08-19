function Get-O365News{
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/searchadminapi/news"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output

    $Uri = "https://admin.microsoft.com/admin/api/searchadminapi/news/options"
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
}