Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365OrgVivaSettings' {
    It 'uses the modules endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/'; 'x-adminapp-request' = '/viva' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365OrgVivaSettings -Name Modules

        $Result.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/viva/modules'
    }

    It 'uses the account skus endpoint with Viva portal headers' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/'; 'x-adminapp-request' = '/viva' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri; AdditionalHeaders = $AdditionalHeaders } }

        $Result = Get-O365OrgVivaSettings -Name AccountSkus

        $Result.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/tenant/accountSkus'
        $Result.AdditionalHeaders['x-adminapp-request'] | Should -Be '/viva'
    }

    It 'returns grouped data for All' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/'; 'x-adminapp-request' = '/viva' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365OrgVivaSettings

        $Result.Modules.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/viva/modules'
        $Result.AccountSkus.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/tenant/accountSkus'
    }

    It 'returns a placeholder when Glint client data is unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/'; 'x-adminapp-request' = '/viva' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365OrgVivaSettings -Name GlintClient

        $Result.Name | Should -Be 'GlintClient'
        $Result.DataBacked | Should -BeFalse
        $Result.Reason | Should -Be 'ServiceError'
        $Result.IsOptional | Should -BeTrue
        $Result.Description | Should -Match 'HTTP 500'
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/vivaglint/clientDiscovery/transformed' -and
            $QuietOnError
        } -Exactly 1
    }

    It 'prefers portal session replay when Viva portal metadata is available' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/'; 'x-adminapp-request' = '/viva'; AjaxSessionKey = 'ajax-key'; 'x-portal-routekey' = 'frc-uas' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365OrgVivaSettings -Headers @{ AjaxSessionKey = 'ajax-key'; PortalRouteKey = 'frc-uas'; PortalWebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new() } -Name AccountSkus

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/tenant/accountSkus' -and
            $UsePortalSession -and
            $AdditionalHeaders.AjaxSessionKey -eq 'ajax-key' -and
            $AdditionalHeaders['x-portal-routekey'] -eq 'frc-uas'
        } -Exactly 1
    }
}
