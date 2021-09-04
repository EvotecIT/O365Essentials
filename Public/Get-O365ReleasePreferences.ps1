function Get-O365OrgReleasePreferences {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/Settings/company/releasetrack"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}