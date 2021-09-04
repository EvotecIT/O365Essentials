function Get-O365OrgOfficeOnTheWeb {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/officeonline"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}