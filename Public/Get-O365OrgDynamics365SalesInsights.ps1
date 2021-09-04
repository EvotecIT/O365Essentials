function Get-O365OrgDynamics365SalesInsights {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/admin/api/settings/apps/dci'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}