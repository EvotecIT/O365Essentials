function Get-O365Planner {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/services/apps/planner"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}