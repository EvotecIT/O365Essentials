function Get-O365OrgVivaSettings {
    <#
    .SYNOPSIS
    Retrieves Viva admin-center settings for the organization.

    .DESCRIPTION
    Reads internal Viva admin-center payloads such as modules, roles, Glint client
    metadata, and the tenant account SKU feed used by the Viva experience.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which Viva payload to return.

    .EXAMPLE
    Get-O365OrgVivaSettings

    .EXAMPLE
    Get-O365OrgVivaSettings -Name Modules
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('AccountSkus', 'All', 'GlintClient', 'Modules', 'Roles')][string] $Name = 'All'
    )

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context Viva -PortalHost 'https://admin.cloud.microsoft' -AjaxSessionKey $Headers.AjaxSessionKey -PortalRouteKey $Headers.PortalRouteKey
    $UsePortalSession = $false
    if ($Headers) {
        if ($Headers.Contains('AjaxSessionKey') -and -not [string]::IsNullOrWhiteSpace($Headers['AjaxSessionKey'])) {
            $UsePortalSession = $true
        }
        elseif ($Headers.Contains('PortalWebSession') -and $null -ne $Headers['PortalWebSession']) {
            $UsePortalSession = $true
        }
    }

    if ($Name -eq 'All') {
        [PSCustomObject] @{
            Modules     = Get-O365OrgVivaSettings -Headers $Headers -Name Modules
            Roles       = Get-O365OrgVivaSettings -Headers $Headers -Name Roles
            GlintClient = Get-O365OrgVivaSettings -Headers $Headers -Name GlintClient
            AccountSkus = Get-O365OrgVivaSettings -Headers $Headers -Name AccountSkus
        }
        return
    }

    $Uri = switch ($Name) {
        'AccountSkus' { 'https://admin.cloud.microsoft/admin/api/tenant/accountSkus' }
        'GlintClient' { 'https://admin.cloud.microsoft/admin/api/vivaglint/clientDiscovery/transformed' }
        'Modules' { 'https://admin.cloud.microsoft/admin/api/viva/modules' }
        'Roles' { 'https://admin.cloud.microsoft/admin/api/viva/roles' }
    }

    $UnavailableSplat = @{}
    if ($Name -eq 'GlintClient') {
        $UnavailableSplat = @{
            UnavailableDescription     = 'The Viva Glint client discovery route did not return usable data. Live browser validation for this tenant also returned HTTP 500 from the same endpoint.'
            UnavailableReason          = 'ServiceError'
            UnavailableSuggestedAction = 'Treat this as a tenant or service-side Viva Glint issue unless the live admin portal starts returning a successful response for this route.'
            UnavailableIsOptional      = $true
        }
    }

    Get-VivaSettingsSafeResult -ResultName $Name @UnavailableSplat -ScriptBlock {
        $Splat = @{
            Uri               = $Uri
            Headers           = $Headers
            Method            = 'GET'
            AdditionalHeaders = $AdditionalHeaders
            UsePortalSession  = $UsePortalSession
        }
        if ($Name -eq 'GlintClient') {
            $Splat['QuietOnError'] = $true
        }
        Invoke-O365Admin @Splat
    }
}
