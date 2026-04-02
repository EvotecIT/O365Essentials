Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365TenantRelationship' {
    It 'uses the tenants endpoint for Tenants view' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }
        Get-O365TenantRelationship -Name Tenants
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/tenantRelationships/multiTenantOrganization/tenants'
        } -Exactly 1
    }

    It 'returns grouped data for All' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }
        $Result = Get-O365TenantRelationship
        $Result.MultiTenantOrganization.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/tenantRelationships/multiTenantOrganization'
        $Result.UserSyncAppOutboundDetails.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/tenantRelationships/userSyncApps/outboundDetails'
    }

    It 'returns a placeholder when tenant data is unavailable' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365TenantRelationship -Name Tenants

        $Result.Name | Should -Be 'Tenants'
        $Result.DataBacked | Should -BeFalse
    }
}
