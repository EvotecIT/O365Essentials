function Get-O365OrgVivaLearning {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/admin/api/settings/apps/learning'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}