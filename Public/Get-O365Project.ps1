function Get-O365Project {
    [cmdletbinding()]
    param(
        [parameter(Mandatory)][alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/projectonline"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers.Headers
    $Output
}