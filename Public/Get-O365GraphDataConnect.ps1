function Get-O365GraphDataConnect {
    [cmdletbinding()]
    param(
        [parameter(Mandatory)][alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/o365dataplan"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers.Headers
    $Output
}