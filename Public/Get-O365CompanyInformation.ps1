function Get-O365CompanyInformation {
    [cmdletbinding()]
    param(
        [parameter(Mandatory)][alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/Settings/company/profile"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers.Headers
    $Output
}