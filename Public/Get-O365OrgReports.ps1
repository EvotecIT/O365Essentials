function Get-O365OrgReports {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/reports/config/GetTenantConfiguration"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $OutputFromJson = $Output.Output | ConvertFrom-Json
    $OutputFromJson
}