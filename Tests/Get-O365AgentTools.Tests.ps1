Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365AgentTools' {
    It 'uses the MCP servers endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }
        Get-O365AgentTools -Name McpServers
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/agentssettings/mcpservers'
        } -Exactly 1
    }

    It 'returns a placeholder when MCP servers data is unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365AgentTools -Name McpServers

        $Result.Name | Should -Be 'McpServers'
        $Result.DataBacked | Should -BeFalse
    }

    It 'prefers portal session replay when portal session metadata is available' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/'; AjaxSessionKey = 'ajax-key'; 'x-portal-routekey' = 'weu' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365AgentTools -Headers @{ AjaxSessionKey = 'ajax-key'; PortalRouteKey = 'weu'; PortalWebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new() } -Name McpServers

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/agentssettings/mcpservers' -and
            $UsePortalSession -and
            $AdditionalHeaders.AjaxSessionKey -eq 'ajax-key' -and
            $AdditionalHeaders['x-portal-routekey'] -eq 'weu'
        } -Exactly 1
    }
}
