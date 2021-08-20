function Get-O365CustomThemes {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/Settings/company/theme/v2"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output.ThemeData
}