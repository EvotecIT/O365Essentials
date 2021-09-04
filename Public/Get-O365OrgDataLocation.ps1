function Get-O365OrgDataLocation {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/tenant/datalocation"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}