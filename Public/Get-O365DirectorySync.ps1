function Get-O365DirectorySync {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/dirsync"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}