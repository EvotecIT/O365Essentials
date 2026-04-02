Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365AgentOverview' {
    It 'uses the risky agents endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }
        Get-O365AgentOverview -Name RiskyAgents
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/agentusers/metrics/agents/risky?maxCount=3' -and
            $AdditionalHeaders['x-adminapp-request'] -eq '/agents/overview' -and
            $QuietOnError
        } -Exactly 1
    }

    It 'uses browser-aligned addins headers for agent inventory endpoints' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365AgentOverview -Name Agents
        Get-O365AgentOverview -Name ActionableApps
        Get-O365AgentOverview -Name AgentInsights

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/fd/addins/api/agents?workloads=SharedAgent&scopes=Shared&limit=200&creatorId=none' -and
            $AdditionalHeaders['x-adminapp-request'] -eq '/agents/overview' -and
            $AdditionalHeaders['x-admin-portal-flight'] -eq 'UDShowTeamsAppInAvailableList,UDAddInToMosUpdateEnabled,UDAIAdminEnabled' -and
            $AdditionalHeaders['x-usage-origin'] -eq 'AgentsOverview'
        } -Exactly 1
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/fd/addins/api/actionableApps?workloads=MetaOS%2CSharedAgent&limit=200' -and
            $AdditionalHeaders['x-adminapp-request'] -eq '/agents/overview' -and
            $AdditionalHeaders['x-admin-portal-flight'] -eq 'UDShowTeamsAppInAvailableList,UDAddInToMosUpdateEnabled,UDAIAdminEnabled' -and
            $AdditionalHeaders['x-usage-origin'] -eq 'CopilotSettings'
        } -Exactly 1
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/fd/addins/api/apps/insight?workload=SharedAgent&entraScopes=EntraAgentBlueprintSP,EntraAgentPVA,EntraAgentIdentity' -and
            $AdditionalHeaders['x-adminapp-request'] -eq '/agents/overview' -and
            $AdditionalHeaders['x-admin-portal-flight'] -eq 'UDShowTeamsAppInAvailableList,UDAddInToMosUpdateEnabled,UDAIAdminEnabled' -and
            $AdditionalHeaders['x-usage-origin'] -eq 'AgentsOverview'
        } -Exactly 1
    }

    It 'builds a summary view from agent insights and risky agents' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            if ($Uri -like '*apps/insight*') {
                [pscustomobject] @{
                    data = [pscustomobject] @{
                        titlesInsight = [pscustomobject] @{
                            Counts = [pscustomobject] @{
                                OrphanedAgents = 2
                                AgentAggregatedMetricsResponse = [pscustomobject] @{
                                    summary = [pscustomobject] @{
                                        totalAgents = 12
                                        totalAgentsLastWeek = 10
                                        blockedAgents = 1
                                        totalRiskyAgentCount = 4
                                    }
                                    countsByAppType = @('Declarative')
                                    countsByBuilder = @('Microsoft')
                                }
                            }
                        }
                    }
                }
            } elseif ($Uri -like '*metrics/agents/risky*') {
                [pscustomobject] @{
                    totalRiskyAgentCount = 5
                    riskyAgentsDetails = @('A1')
                }
            }
        }
        $Result = Get-O365AgentOverview -Name Summary
        $Result.TotalAgents | Should -Be 12
        $Result.TotalRiskyAgentCount | Should -Be 5
        $Result.OrphanedAgents | Should -Be 2
    }

    It 'treats null offer recommendation payloads as valid no-offer results' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365AgentOverview -Name OfferRecommendations

        $Result.Offer48.DataBacked | Should -BeTrue
        $Result.Offer48.NoData | Should -BeTrue
        $Result.Offer48.HasOffer | Should -BeFalse
        $Result.Offer49.DataBacked | Should -BeTrue
        $Result.Offer49.NoData | Should -BeTrue
        $Result.Offer49.HasOffer | Should -BeFalse
    }

    It 'returns a placeholder when risky agents data is unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365AgentOverview -Name RiskyAgents

        $Result.Name | Should -Be 'RiskyAgents'
        $Result.Reason | Should -Be 'TenantSpecific'
        $Result.DataBacked | Should -BeFalse
    }

    It 'falls back to agent insights when risky agents endpoint is unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            if ($Uri -like '*metrics/agents/risky*') {
                return $null
            }
            if ($Uri -like '*apps/insight*') {
                return [pscustomobject] @{
                    data = [pscustomobject] @{
                        titlesInsight = [pscustomobject] @{
                            Counts = [pscustomobject] @{
                                AgentAggregatedMetricsResponse = [pscustomobject] @{
                                    summary = [pscustomobject] @{
                                        totalRiskyAgentCount = 7
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        $Result = Get-O365AgentOverview -Name RiskyAgents

        $Result.totalRiskyAgentCount | Should -Be 7
        $Result.FallbackUsed | Should -BeTrue
        $Result.FallbackName | Should -Be 'AgentInsights'
    }

    It 'prefers portal session replay when portal session metadata is available' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/'; AjaxSessionKey = 'ajax-key'; 'x-portal-routekey' = 'weu' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365AgentOverview -Headers @{ AjaxSessionKey = 'ajax-key'; PortalRouteKey = 'weu'; PortalWebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new() } -Name RiskyAgents

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/agentusers/metrics/agents/risky?maxCount=3' -and
            $UsePortalSession -and
            $AdditionalHeaders['x-adminapp-request'] -eq '/agents/overview' -and
            $AdditionalHeaders.AjaxSessionKey -eq 'ajax-key' -and
            $AdditionalHeaders['x-portal-routekey'] -eq 'weu'
        } -Exactly 1
    }
}
