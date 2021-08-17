function Get-O365ToDo {
    [cmdletbinding()]
    param(
        [parameter(Mandatory)][alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/todo"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers.Headers
    $Output
}