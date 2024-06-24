function Set-O365OrgPrivilegedAccess {
    <#
        .SYNOPSIS
        Configures the privileged access settings for an Office 365 organization.
        .DESCRIPTION
        This function updates the privileged access settings for an Office 365 organization. It allows enabling or disabling the Tenant Lockbox feature and specifying an admin group.
        .PARAMETER Headers
        Specifies the headers for the API request. Typically includes authorization tokens.
        .PARAMETER TenantLockBoxEnabled
        Specifies whether the Tenant Lockbox feature should be enabled or disabled. Accepts a nullable boolean value.
        .PARAMETER AdminGroup
        Specifies the admin group for privileged access.
        .EXAMPLE
        $headers = @{Authorization = "Bearer your_token"}
        Set-O365OrgPrivilegedAccess -Headers $headers -TenantLockBoxEnabled $true -AdminGroup "AdminGroupName"

        This example enables the Tenant Lockbox feature and sets the admin group to "AdminGroupName".
    #>
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
