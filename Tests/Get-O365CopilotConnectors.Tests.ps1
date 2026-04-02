Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365CopilotConnectors' {
    It 'uses the summary endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/?' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }
        Get-O365CopilotConnectors -Name Summary
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/searchadminapi/UDTConnectorsSummary'
        } -Exactly 1
    }

    It 'builds the YourConnections bundle' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/?' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }
        $Result = Get-O365CopilotConnectors -Name YourConnections
        $Result.Summary.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/searchadminapi/UDTConnectorsSummary'
        $Result.Connections.Uri | Should -Be 'https://admin.cloud.microsoft/fd/mssearchconnectors/v1.0/admin/connections/v2?filterActive=false&useCachedRead=true&includeFederatedConnections=true'
    }

    It 'uses the live admin.cloud.microsoft connector routes' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/?' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365CopilotConnectors -Name Statistics
        Get-O365CopilotConnectors -Name Connections
        Get-O365CopilotConnectors -Name AdminUxOptions

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/fd/mssearchconnectors/v1.0/admin/connections/getStatistics'
        } -Exactly 1
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/fd/mssearchconnectors/v1.0/admin/connections/v2?filterActive=false&useCachedRead=true&includeFederatedConnections=true'
        } -Exactly 1
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/fd/mssearchconnectors/v1.0/admin/AdminUxOptionsV2/Connectors?query=Connectors'
        } -Exactly 1
    }

    It 'uses the live gallery settings route and anchor mailbox shape' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/'; 'x-adminapp-request' = '/copilot/connectors'; 'x-ms-mac-appid' = 'e103e082-0998-4474-af03-186c96afc209' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365CopilotConnectors -Headers @{ Tenant = 'ceb371f6-8745-4876-a040-69f2d10a9d1a' } -Name GallerySettings

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq "https://admin.cloud.microsoft/fd/ssms/api/v1.0/'FSS'/Collection('Staging')/Settings/?`$filter=Path%20eq%20'%3A'" -and
            $AdditionalHeaders['x-adminapp-request'] -eq '/copilot/connectors' -and
            $AdditionalHeaders['x-ms-mac-appid'] -eq 'e103e082-0998-4474-af03-186c96afc209' -and
            $AdditionalHeaders['x-anchormailbox'] -eq 'APP:TenantSetting_AC9A8876-0461-47EA-9d4C-FE8D02AEF7D5@ceb371f6-8745-4876-a040-69f2d10a9d1a'
        } -Exactly 1
    }

    It 'returns a placeholder when summary data is unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/?' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365CopilotConnectors -Name Summary

        $Result.Name | Should -Be 'Summary'
        $Result.Reason | Should -Be 'PortalSessionRequired'
        $Result.DataBacked | Should -BeFalse
    }

    It 'prefers portal session replay for admin.cloud.microsoft summary routes when portal metadata is available' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/'; AjaxSessionKey = 'ajax-key'; 'x-portal-routekey' = 'weu' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365CopilotConnectors -Headers @{ AjaxSessionKey = 'ajax-key'; PortalRouteKey = 'weu'; PortalWebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new() } -Name Summary

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/searchadminapi/UDTConnectorsSummary' -and
            $UsePortalSession -and
            $AdditionalHeaders.AjaxSessionKey -eq 'ajax-key' -and
            $AdditionalHeaders['x-portal-routekey'] -eq 'weu'
        } -Exactly 1
    }
}
