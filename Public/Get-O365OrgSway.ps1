function Get-O365OrgSway {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/Sway"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}