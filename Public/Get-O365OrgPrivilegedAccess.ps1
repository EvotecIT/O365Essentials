function Get-O365OrgPrivilegedAccess {
    <#
    .SYNOPSIS
    Retrieves the organization's privileged access settings.

    .DESCRIPTION
    Reads the Microsoft 365 privileged access configuration, including whether
    approvals are required and the default approvers group.

    .PARAMETER Headers
    Authorization cache returned by Connect-O365Admin. When omitted, the module's
    cached connection is used.

    .EXAMPLE
    $Authorization = Connect-O365Admin -UseWam
    Get-O365OrgPrivilegedAccess -Headers $Authorization
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = 'https://admin.microsoft.com/admin/api/Settings/security/tenantLockbox'
    Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -ErrorAction Stop
}
