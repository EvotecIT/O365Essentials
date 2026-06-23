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
    $Uri = "https://admin.microsoft.com/admin/api/Settings/security/tenantLockbox"
    $CurrentSettings = Get-O365OrgPrivilegedAccess -Headers $Headers

    if (-not $CurrentSettings) {
        Write-Warning -Message 'Set-O365OrgPrivilegedAccess - Current privileged access settings could not be read.'
        return
    }

    $EnabledTenantLockbox = if ($PSBoundParameters.ContainsKey('TenantLockBoxEnabled')) {
        [bool] $TenantLockBoxEnabled
    } else {
        [bool] $CurrentSettings.EnabledTenantLockbox
    }
    $ResolvedAdminGroup = if ($PSBoundParameters.ContainsKey('AdminGroup')) {
        $AdminGroup
    } else {
        $CurrentSettings.AdminGroup
    }

    if ($EnabledTenantLockbox -and [string]::IsNullOrWhiteSpace($ResolvedAdminGroup)) {
        Write-Warning -Message 'Set-O365OrgPrivilegedAccess - AdminGroup is required when Tenant Lockbox is enabled.'
        return
    }

    $Body = [ordered] @{
        EnabledTenantLockbox = $EnabledTenantLockbox
        AdminGroup           = $ResolvedAdminGroup
        Identity             = $CurrentSettings.Identity
    }
    if ($PSCmdlet.ShouldProcess($Uri, 'Update privileged access settings')) {
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
        $Output
    }
}
