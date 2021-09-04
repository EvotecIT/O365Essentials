function Get-O365OrgCortana {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/admin/api/services/apps/cortana'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}