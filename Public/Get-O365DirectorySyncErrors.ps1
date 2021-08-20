function Get-O365DirectorySyncErrors {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/dirsyncerrors/listdirsyncerrors"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST
    $Output
}