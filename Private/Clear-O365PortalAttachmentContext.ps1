function Clear-O365PortalAttachmentContext {
    <#
    .SYNOPSIS
    Clears hidden portal attachment context seeded for Connect-O365Admin.

    .DESCRIPTION
    Removes process-scoped environment variables used to transparently attach an
    admin.cloud.microsoft portal session during Connect-O365Admin.

    .EXAMPLE
    Clear-O365PortalAttachmentContext
    #>
    [cmdletbinding()]
    param()

    $EnvironmentNames = @(
        'O365ESSENTIALS_PORTAL_ROOT_AUTH_TOKEN',
        'O365ESSENTIALS_PORTAL_SPA_AUTH_COOKIE',
        'O365ESSENTIALS_PORTAL_OIDC_AUTH_COOKIE',
        'O365ESSENTIALS_PORTAL_AJAX_SESSION_KEY',
        'O365ESSENTIALS_PORTAL_SESSION_ID',
        'O365ESSENTIALS_PORTAL_TENANT_ID',
        'O365ESSENTIALS_PORTAL_ROUTE_KEY',
        'O365ESSENTIALS_PORTAL_USERNAME',
        'O365ESSENTIALS_PORTAL_SKIP_BOOTSTRAP',
        'O365ESSENTIALS_PORTAL_CLEAR_AFTER_READ'
    )

    $Removed = [System.Collections.Generic.List[string]]::new()
    foreach ($EnvironmentName in $EnvironmentNames) {
        if (-not [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($EnvironmentName, 'Process'))) {
            $Removed.Add($EnvironmentName)
        }
        [Environment]::SetEnvironmentVariable($EnvironmentName, $null, 'Process')
    }

    [PSCustomObject] @{
        Cleared = $true
        RemovedCount = $Removed.Count
        RemovedNames = @($Removed)
    }
}
