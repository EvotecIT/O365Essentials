function Get-O365TeamsTenantWideAppsSettings {
    <#
    .SYNOPSIS
    Gets tenant-wide Teams app settings.

    .DESCRIPTION
    Reads the tenant-wide app settings used by the Microsoft Teams admin center.
    The command uses the Teams authorization headers returned by Connect-O365Admin.

    This command calls an undocumented beta endpoint. Microsoft can change that
    endpoint without notice.

    .PARAMETER Headers
    Authorization cache returned by Connect-O365Admin. When omitted, the module's
    cached connection is used.

    .PARAMETER Region
    Regional Teams API route. Supported values are emea, amer, and apac.

    .EXAMPLE
    $Authorization = Connect-O365Admin -UseWam
    Get-O365TeamsTenantWideAppsSettings -Headers $Authorization -Region emea

    Reads the current tenant-wide Teams app settings for the EMEA region.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('emea', 'amer', 'apac')][string] $Region = 'emea'
    )

    $Uri = "https://teams.microsoft.com/api/mt/$Region/beta/users/tenantWideAppsSettings"
    Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET
}
