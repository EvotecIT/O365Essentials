function Get-O365Dynamics365ConnectionGraph {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/admin/api/settings/apps/dcg'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}