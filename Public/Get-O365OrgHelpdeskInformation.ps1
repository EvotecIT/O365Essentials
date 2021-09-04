function Get-O365OrgHelpdeskInformation {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/Settings/company/helpdesk"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}