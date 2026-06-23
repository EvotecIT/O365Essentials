function Get-FindingPriority {
    [cmdletbinding()]
    param(
        [string] $Reason,
        [bool] $IsOptional
    )

    if ($IsOptional) {
        return 'Low'
    }

    switch ($Reason) {
        'AuthorizationError' { 'High' }
        'MissingTenantId' { 'High' }
        'PortalSessionRequired' { 'High' }
        'ValidationError' { 'High' }
        'UndiscoveredEndpoint' { 'High' }
        'TenantSpecific' { 'Medium' }
        default {
            if ([string]::IsNullOrWhiteSpace($Reason)) { 'Info' } else { 'Medium' }
        }
    }
}
