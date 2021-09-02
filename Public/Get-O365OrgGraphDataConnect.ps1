function Get-O365OrgGraphDataConnect {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/o365dataplan"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}