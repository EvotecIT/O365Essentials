function Get-O365OrgCustomerLockbox {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/security/dataaccess"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}