function Get-O365Sway {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/Sway"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}