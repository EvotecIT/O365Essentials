function Get-O365DirectorySyncManagement {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/DirsyncManagement/manage"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}