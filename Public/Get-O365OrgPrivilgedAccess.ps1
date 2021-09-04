function Get-O365OrgPrivilegedAccess {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/Settings/security/tenantLockbox"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}