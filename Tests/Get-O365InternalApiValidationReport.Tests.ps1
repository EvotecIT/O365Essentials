Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365InternalApiValidationReport' {
    It 'builds a prioritized report from health and findings' {
        Mock -ModuleName O365Essentials Get-O365InternalApiHealth -MockWith {
            @(
                [pscustomobject] @{
                    Area                = 'Copilot'
                    Mode                = 'Standard'
                    Status              = 'Partial'
                    ElapsedMilliseconds = 120
                    UnavailableCount    = 1
                    Components          = @(
                        [pscustomobject] @{
                            Name                = 'Recommendations'
                            Status              = 'Unavailable'
                            ElapsedMilliseconds = 90
                            SuggestedCommand    = 'Get-O365CopilotSettings -Name Recommendations'
                            UnavailableCount    = 1
                        },
                        [pscustomobject] @{
                            Name                = 'ConnectorsSummary'
                            Status              = 'Healthy'
                            ElapsedMilliseconds = 30
                            SuggestedCommand    = 'Get-O365CopilotConnectors -Name Summary'
                            UnavailableCount    = 0
                        }
                    )
                },
                [pscustomobject] @{
                    Area                = 'Viva'
                    Mode                = 'Standard'
                    Status              = 'Healthy'
                    ElapsedMilliseconds = 35
                    UnavailableCount    = 0
                    Components          = @(
                        [pscustomobject] @{
                            Name                = 'Modules'
                            Status              = 'Healthy'
                            ElapsedMilliseconds = 35
                            SuggestedCommand    = 'Get-O365OrgVivaSettings -Name Modules'
                            UnavailableCount    = 0
                        }
                    )
                }
            )
        }
        Mock -ModuleName O365Essentials Get-O365InternalApiFinding -MockWith {
            @(
                [pscustomobject] @{
                    Area             = 'Copilot'
                    Mode             = 'Standard'
                    AreaStatus       = 'Partial'
                    Component        = 'Security'
                    ComponentStatus  = 'Partial'
                    ComponentElapsedMilliseconds = 220
                    Name             = 'PurviewSettings'
                    Reason           = 'TenantSpecific'
                    IsOptional       = $false
                    Path             = '$.Security.PurviewSettings'
                    Description      = 'Unavailable in this tenant.'
                    SuggestedAction  = 'Check tenant features.'
                    SuggestedCommand = 'Get-O365CopilotOverview -Name Security'
                }
            )
        }

        $Report = Get-O365InternalApiValidationReport -Area Copilot, Viva

        $Report.Summary.AreaCount | Should -Be 2
        $Report.Summary.PartialAreas | Should -Be 1
        $Report.Summary.HealthyAreas | Should -Be 1
        $Report.Summary.TotalElapsedMilliseconds | Should -Be 155
        $Report.PrioritizedFindings[0].Priority | Should -Be 'Medium'
        $Report.PrioritizedFindings[0].ComponentElapsedMilliseconds | Should -Be 220
        $Report.SlowestAreas[0].Area | Should -Be 'Copilot'
        $Report.SlowestComponents[0].Component | Should -Be 'Recommendations'
        $Report.RecommendedCommands | Should -Contain 'Get-O365CopilotOverview -Name Security'
    }

    It 'assigns high priority to validation and authorization failures' {
        Mock -ModuleName O365Essentials Get-O365InternalApiHealth -MockWith { @([pscustomobject] @{ Area = 'People'; Mode = 'Standard'; Status = 'Unavailable'; Components = @() }) }
        Mock -ModuleName O365Essentials Get-O365InternalApiFinding -MockWith {
            @(
                [pscustomobject] @{
                    Area             = 'People'
                    Mode             = 'Standard'
                    AreaStatus       = 'Unavailable'
                    Component        = 'Pronouns'
                    ComponentStatus  = 'Unavailable'
                    ComponentElapsedMilliseconds = 180
                    Name             = 'Pronouns'
                    Reason           = 'AuthorizationError'
                    IsOptional       = $false
                    Path             = '$.Pronouns'
                    Description      = 'Auth missing.'
                    SuggestedAction  = 'Reconnect.'
                    SuggestedCommand = 'Get-O365OrgPeopleSettings -Name Pronouns'
                }
            )
        }

        $Report = Get-O365InternalApiValidationReport -Area People

        $Report.PrioritizedFindings[0].Priority | Should -Be 'High'
        $Report.Summary.HighPriorityCount | Should -Be 1
    }

    It 'assigns high priority to portal-session-required findings' {
        Mock -ModuleName O365Essentials Get-O365InternalApiHealth -MockWith { @([pscustomobject] @{ Area = 'Search'; Mode = 'Standard'; Status = 'Unavailable'; Components = @() }) }
        Mock -ModuleName O365Essentials Get-O365InternalApiFinding -MockWith {
            @(
                [pscustomobject] @{
                    Area             = 'Search'
                    Mode             = 'Standard'
                    AreaStatus       = 'Unavailable'
                    Component        = 'ConfigurationSettings'
                    ComponentStatus  = 'Unavailable'
                    ComponentElapsedMilliseconds = 260
                    Name             = 'ConfigurationSettings'
                    Reason           = 'PortalSessionRequired'
                    IsOptional       = $false
                    Path             = '$.ConfigurationSettings'
                    Description      = 'Portal session needed.'
                    SuggestedAction  = 'Replay with portal session.'
                    SuggestedCommand = 'Get-O365SearchIntelligenceAdvanced -Name ConfigurationSettings'
                }
            )
        }

        $Report = Get-O365InternalApiValidationReport -Area Search

        $Report.PrioritizedFindings[0].Priority | Should -Be 'High'
        $Report.Summary.HighPriorityCount | Should -Be 1
    }

    It 'can include healthy findings when requested' {
        Mock -ModuleName O365Essentials Get-O365InternalApiHealth -MockWith { @([pscustomobject] @{ Area = 'Viva'; Mode = 'Standard'; Status = 'Healthy'; Components = @() }) }
        Mock -ModuleName O365Essentials Get-O365InternalApiFinding -MockWith {
            @(
                [pscustomobject] @{
                    Area             = 'Viva'
                    Mode             = 'Standard'
                    AreaStatus       = 'Healthy'
                    Component        = 'Modules'
                    ComponentStatus  = 'Healthy'
                    ComponentElapsedMilliseconds = 20
                    Name             = $null
                    Reason           = $null
                    IsOptional       = $false
                    Path             = $null
                    Description      = $null
                    SuggestedAction  = $null
                    SuggestedCommand = 'Get-O365OrgVivaSettings -Name Modules'
                }
            )
        }

        $Report = Get-O365InternalApiValidationReport -Area Viva -IncludeHealthyFindings

        Assert-MockCalled Get-O365InternalApiFinding -ModuleName O365Essentials -ParameterFilter { $IncludeHealthy } -Exactly 1
        $Report.Summary.InfoCount | Should -Be 1
        $Report.RecommendedCommands | Should -Contain 'Get-O365OrgVivaSettings -Name Modules'
    }

    It 'assigns low priority to optional findings' {
        Mock -ModuleName O365Essentials Get-O365InternalApiHealth -MockWith { @([pscustomobject] @{ Area = 'MicrosoftEdge'; Mode = 'Standard'; Status = 'Partial'; Components = @() }) }
        Mock -ModuleName O365Essentials Get-O365InternalApiFinding -MockWith {
            @(
                [pscustomobject] @{
                    Area             = 'MicrosoftEdge'
                    Mode             = 'Standard'
                    AreaStatus       = 'Partial'
                    Component        = 'Notifications'
                    ComponentStatus  = 'Unavailable'
                    ComponentElapsedMilliseconds = 75
                    Name             = 'Notifications'
                    Reason           = 'TenantSpecific'
                    IsOptional       = $true
                    Path             = '$.Notifications'
                    Description      = 'Optional feed.'
                    SuggestedAction  = 'Validate only if expected.'
                    SuggestedCommand = 'Get-O365OrgMicrosoftEdgeSiteLists -Name Notifications'
                }
            )
        }

        $Report = Get-O365InternalApiValidationReport -Area MicrosoftEdge

        $Report.PrioritizedFindings[0].Priority | Should -Be 'Low'
        $Report.Summary.LowPriorityCount | Should -Be 1
    }
}
