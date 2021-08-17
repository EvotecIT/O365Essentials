function Get-O365Dynamics365SalesInsights {
    [cmdletbinding()]
    param(
        [parameter(Mandatory)][alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/admin/api/settings/apps/dci'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers.Headers
    $Output
}