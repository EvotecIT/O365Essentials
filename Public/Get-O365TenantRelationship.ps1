function Get-O365TenantRelationship {
    <#
    .SYNOPSIS
    Retrieves Microsoft 365 tenant relationship data from the admin center.

    .DESCRIPTION
    This function reads multi-tenant organization and related tenant relationship payloads
    from internal Microsoft 365 admin center endpoints.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which tenant relationship payload to return.

    .EXAMPLE
    Get-O365TenantRelationship

    .EXAMPLE
    Get-O365TenantRelationship -Name Tenants
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('All', 'MultiTenantOrganization', 'OrganizationRelationships', 'RemovedTenants', 'Tenants', 'UserSyncAppOutboundDetails')][string] $Name = 'All'
    )

    function Get-TenantRelationshipSafeResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            $Result = & $ScriptBlock
            if ($null -eq $Result) {
                New-O365UnavailableResult -Name $ResultName -Area 'Tenant relationship section' -Description 'The tenant relationship section did not return a usable payload.'
            } else {
                $Result
            }
        } catch {
            New-O365UnavailableResult -Name $ResultName -Area 'Tenant relationship section' -Description 'The tenant relationship section did not return a usable payload.' -ErrorMessage $_.Exception.Message
        }
    }

    if ($Name -eq 'All') {
        [PSCustomObject] @{
            MultiTenantOrganization   = Get-O365TenantRelationship -Headers $Headers -Name MultiTenantOrganization
            OrganizationRelationships = Get-O365TenantRelationship -Headers $Headers -Name OrganizationRelationships
            Tenants                   = Get-O365TenantRelationship -Headers $Headers -Name Tenants
            RemovedTenants            = Get-O365TenantRelationship -Headers $Headers -Name RemovedTenants
            UserSyncAppOutboundDetails = Get-O365TenantRelationship -Headers $Headers -Name UserSyncAppOutboundDetails
        }
        return
    }

    $Uri = switch ($Name) {
        'MultiTenantOrganization' { 'https://admin.cloud.microsoft/admin/api/tenantRelationships/multiTenantOrganization' }
        'OrganizationRelationships' { 'https://admin.cloud.microsoft/admin/api/tenantRelationships/orgRelationships' }
        'RemovedTenants' { 'https://admin.cloud.microsoft/admin/api/tenantRelationships/multiTenantOrganization/removedTenants' }
        'Tenants' { 'https://admin.cloud.microsoft/admin/api/tenantRelationships/multiTenantOrganization/tenants' }
        'UserSyncAppOutboundDetails' { 'https://admin.cloud.microsoft/admin/api/tenantRelationships/userSyncApps/outboundDetails' }
    }

    Get-TenantRelationshipSafeResult -ResultName $Name -ScriptBlock { Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET }
}
