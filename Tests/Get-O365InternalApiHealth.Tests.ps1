Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365InternalApiHealth' {
    BeforeAll {
        . "$PSScriptRoot/../Private/New-O365UnavailableResult.ps1"
    }

    It 'returns a healthy standard summary for Agents when all components are healthy' {
        Mock -ModuleName O365Essentials Get-O365AgentSettings -MockWith { [pscustomobject] @{ Name = 'Settings' } }
        Mock -ModuleName O365Essentials Get-O365AgentTools -MockWith { [pscustomobject] @{ Name = 'Tools' } }
        Mock -ModuleName O365Essentials Get-O365AgentOverview -MockWith { [pscustomobject] @{ Name = $Name } }

        $Result = Get-O365InternalApiHealth -Area Agents

        $Result.Area | Should -Be 'Agents'
        $Result.Status | Should -Be 'Healthy'
        $Result.ComponentCount | Should -Be 4
        $Result.HealthyComponents | Should -Be 4
        $Result.UnavailableCount | Should -Be 0
    }

    It 'marks an area as partial when one component contains unavailable payloads' {
        Mock -ModuleName O365Essentials Get-O365CopilotOverview -MockWith {
            [pscustomobject] @{ Name = $Name }
        }
        Mock -ModuleName O365Essentials Get-O365CopilotSettings -MockWith {
            if ($Name -eq 'Recommendations') {
                New-O365UnavailableResult -Name 'Recommendations' -Description 'Unavailable in this tenant.'
            } else {
                [pscustomobject] @{ Name = $Name }
            }
        }
        Mock -ModuleName O365Essentials Get-O365CopilotConnectors -MockWith { [pscustomobject] @{ Name = $Name } }
        Mock -ModuleName O365Essentials Get-O365CopilotBillingUsage -MockWith { [pscustomobject] @{ Name = $Name } }

        $Result = Get-O365InternalApiHealth -Area Copilot

        $Result.Status | Should -Be 'Partial'
        $Result.UnavailableCount | Should -Be 1
        $Result.UnavailableNames | Should -Contain 'Recommendations'
        (@($Result.Components | Where-Object Status -eq 'Unavailable')).Count | Should -Be 1
    }

    It 'uses deep bundle names for Copilot deep validation' {
        Mock -ModuleName O365Essentials Get-O365CopilotOverview -MockWith { [pscustomobject] @{ Name = $Name } }
        Mock -ModuleName O365Essentials Get-O365CopilotSettings -MockWith { [pscustomobject] @{ Name = $Name } }
        Mock -ModuleName O365Essentials Get-O365CopilotConnectors -MockWith { [pscustomobject] @{ Name = $Name } }
        Mock -ModuleName O365Essentials Get-O365CopilotBillingUsage -MockWith { [pscustomobject] @{ Name = $Name } }

        $null = Get-O365InternalApiHealth -Area Copilot -Mode Deep

        Assert-MockCalled Get-O365CopilotOverview -ModuleName O365Essentials -ParameterFilter { $Name -eq 'All' } -Exactly 1
        Assert-MockCalled Get-O365CopilotSettings -ModuleName O365Essentials -ParameterFilter { $Name -eq 'All' } -Exactly 1
        Assert-MockCalled Get-O365CopilotConnectors -ModuleName O365Essentials -ParameterFilter { $Name -eq 'All' } -Exactly 1
        Assert-MockCalled Get-O365CopilotBillingUsage -ModuleName O365Essentials -ParameterFilter { $Name -eq 'All' } -Exactly 1
    }

    It 'can include the raw result payload when requested' {
        Mock -ModuleName O365Essentials Get-O365TenantRelationship -MockWith {
            [pscustomobject] @{
                Tenants = [pscustomobject] @{ value = @() }
            }
        }

        $Result = Get-O365InternalApiHealth -Area TenantRelationship -Mode Deep -IncludeResult

        $Result.PSObject.Properties.Name | Should -Contain 'Result'
        @($Result.Result.Tenants.value).Count | Should -Be 0
    }

    It 'supports the MicrosoftEdge area in standard mode' {
        Mock -ModuleName O365Essentials Get-O365OrgMicrosoftEdge -MockWith {
            if ($Name -eq 'DeviceCount') {
                [pscustomobject] @{ Count = 10 }
            } else {
                [pscustomobject] @{ Name = $Name }
            }
        }

        $Result = Get-O365InternalApiHealth -Area MicrosoftEdge

        $Result.Area | Should -Be 'MicrosoftEdge'
        $Result.Status | Should -Be 'Healthy'
        $Result.ComponentCount | Should -Be 4
        $Result.Components[0].PSObject.Properties.Name | Should -Contain 'SuggestedCommand'
    }

    It 'supports the Viva area in standard mode' {
        Mock -ModuleName O365Essentials Get-O365OrgVivaSettings -MockWith { [pscustomobject] @{ Name = $Name } }

        $Result = Get-O365InternalApiHealth -Area Viva

        $Result.Area | Should -Be 'Viva'
        $Result.Status | Should -Be 'Healthy'
        $Result.ComponentCount | Should -Be 4
    }

    It 'uses a trimmed standard profile for IntegratedApps' {
        Mock -ModuleName O365Essentials Get-O365OrgIntegratedApps -MockWith { [pscustomobject] @{ Name = $Name } }

        $Result = Get-O365InternalApiHealth -Area IntegratedApps

        $Result.Area | Should -Be 'IntegratedApps'
        $Result.Status | Should -Be 'Healthy'
        $Result.ComponentCount | Should -Be 3
        $Result.Components.Name | Should -Contain 'Settings'
        $Result.Components.Name | Should -Contain 'AvailableApps'
        $Result.Components.Name | Should -Contain 'ActionableApps'
        $Result.Components.Name | Should -Not -Contain 'AppCatalog'
        Assert-MockCalled Get-O365OrgIntegratedApps -ModuleName O365Essentials -ParameterFilter { $Name -eq 'Settings' } -Exactly 1
        Assert-MockCalled Get-O365OrgIntegratedApps -ModuleName O365Essentials -ParameterFilter { $Name -eq 'AvailableApps' } -Exactly 1
        Assert-MockCalled Get-O365OrgIntegratedApps -ModuleName O365Essentials -ParameterFilter { $Name -eq 'ActionableApps' } -Exactly 1
        Assert-MockCalled Get-O365OrgIntegratedApps -ModuleName O365Essentials -ParameterFilter { $Name -eq 'AppCatalog' } -Exactly 0
    }

    It 'includes placeholder details inside component findings' {
        Mock -ModuleName O365Essentials Get-O365OrgVivaSettings -MockWith {
            if ($Name -eq 'GlintClient') {
                New-O365UnavailableResult -Name 'GlintClient' -Description 'Unavailable in this tenant.'
            } else {
                [pscustomobject] @{ Name = $Name }
            }
        }

        $Result = Get-O365InternalApiHealth -Area Viva
        $Component = @($Result.Components | Where-Object Name -eq 'GlintClient')[0]

        $Component.Status | Should -Be 'Unavailable'
        $Component.SuggestedCommand | Should -Be 'Get-O365OrgVivaSettings -Name GlintClient'
        $Component.UnavailableItems.Count | Should -Be 1
        $Component.UnavailableItems[0].Name | Should -Be 'GlintClient'
    }

    It 'records elapsed timing information for each area' {
        Mock -ModuleName O365Essentials Get-O365TenantRelationship -MockWith {
            Start-Sleep -Milliseconds 25
            [pscustomobject] @{ Tenants = [pscustomobject] @{ value = @() } }
        }

        $Result = Get-O365InternalApiHealth -Area TenantRelationship

        $Result.PSObject.Properties.Name | Should -Contain 'StartedAt'
        $Result.PSObject.Properties.Name | Should -Contain 'CompletedAt'
        $Result.PSObject.Properties.Name | Should -Contain 'ElapsedMilliseconds'
        $Result.ElapsedMilliseconds | Should -BeGreaterThan 0
    }

    It 'records elapsed timing information for standard component leaves' {
        Mock -ModuleName O365Essentials Get-O365CopilotSettings -MockWith {
            Start-Sleep -Milliseconds 10
            [pscustomobject] @{ Name = $Name }
        }
        Mock -ModuleName O365Essentials Get-O365CopilotConnectors -MockWith {
            Start-Sleep -Milliseconds 15
            [pscustomobject] @{ Name = $Name }
        }

        $Result = Get-O365InternalApiHealth -Area Copilot
        $Recommendations = @($Result.Components | Where-Object Name -eq 'Recommendations')[0]
        $ConnectorsSummary = @($Result.Components | Where-Object Name -eq 'ConnectorsSummary')[0]

        $Recommendations.PSObject.Properties.Name | Should -Contain 'ElapsedMilliseconds'
        $Recommendations.ElapsedMilliseconds | Should -BeGreaterThan 0
        $ConnectorsSummary.ElapsedMilliseconds | Should -BeGreaterThan 0
    }
}
