function Set-O365OrgPrivilegedAccess {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $TenantLockBoxEnabled,
        [string] $AdminGroup
    )
    $Uri = "https://admin.microsoft.com/admin/api/Settings/security/tenantLockbox"

    $Body = @{
        EnabledTenantLockbox = $TenantLockBoxEnabled
        AdminGroup           = $AdminGroup
        Identity             = $null
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}