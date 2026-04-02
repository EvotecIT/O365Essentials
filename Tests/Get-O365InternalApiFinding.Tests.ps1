Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365InternalApiFinding' {
    BeforeAll {
        . "$PSScriptRoot/../Private/New-O365UnavailableResult.ps1"
    }

    It 'returns flattened unavailable findings from health results' {
        $Health = [pscustomobject] @{
            Area       = 'Copilot'
            Mode       = 'Standard'
            Status     = 'Partial'
            Components = @(
                [pscustomobject] @{
                    Name             = 'Security'
                    Status           = 'Partial'
                    ElapsedMilliseconds = 420
                    SuggestedCommand = 'Get-O365CopilotOverview -Name Security'
                    UnavailableItems = @(
                        [pscustomobject] @{
                            Name        = 'PurviewSettings'
                            Reason      = 'TenantSpecific'
                            Path        = '$.PurviewSettings'
                            Description = 'Unavailable in this tenant.'
                            Result      = (New-O365UnavailableResult -Name 'PurviewSettings' -Description 'Unavailable in this tenant.')
                        }
                    )
                }
            )
        }

        $Result = @($Health | Get-O365InternalApiFinding)

        $Result.Count | Should -Be 1
        $Result[0].Area | Should -Be 'Copilot'
        $Result[0].Component | Should -Be 'Security'
        $Result[0].Name | Should -Be 'PurviewSettings'
        $Result[0].IsOptional | Should -BeFalse
        $Result[0].ComponentElapsedMilliseconds | Should -Be 420
        $Result[0].SuggestedCommand | Should -Be 'Get-O365CopilotOverview -Name Security'
    }

    It 'surfaces optional unavailable placeholders' {
        $Health = [pscustomobject] @{
            Area       = 'MicrosoftEdge'
            Mode       = 'Standard'
            Status     = 'Partial'
            Components = @(
                [pscustomobject] @{
                    Name             = 'Notifications'
                    Status           = 'Unavailable'
                    ElapsedMilliseconds = 95
                    SuggestedCommand = 'Get-O365OrgMicrosoftEdgeSiteLists -Name Notifications'
                    UnavailableItems = @(
                        [pscustomobject] @{
                            Name        = 'Notifications'
                            Reason      = 'TenantSpecific'
                            Path        = '$.Notifications'
                            Description = 'Optional feed.'
                            Result      = (New-O365UnavailableResult -Name 'Notifications' -Description 'Optional feed.' -IsOptional $true)
                        }
                    )
                }
            )
        }

        $Result = @($Health | Get-O365InternalApiFinding)

        $Result.Count | Should -Be 1
        $Result[0].IsOptional | Should -BeTrue
    }

    It 'skips healthy components by default' {
        $Health = [pscustomobject] @{
            Area       = 'Viva'
            Mode       = 'Standard'
            Status     = 'Healthy'
            Components = @(
                [pscustomobject] @{
                    Name             = 'Modules'
                    Status           = 'Healthy'
                    ElapsedMilliseconds = 37
                    SuggestedCommand = 'Get-O365OrgVivaSettings -Name Modules'
                    UnavailableItems = @()
                }
            )
        }

        $Result = @($Health | Get-O365InternalApiFinding)

        $Result.Count | Should -Be 0
    }

    It 'can include healthy components when requested' {
        $Health = [pscustomobject] @{
            Area       = 'Viva'
            Mode       = 'Standard'
            Status     = 'Healthy'
            Components = @(
                [pscustomobject] @{
                    Name             = 'Modules'
                    Status           = 'Healthy'
                    ElapsedMilliseconds = 37
                    SuggestedCommand = 'Get-O365OrgVivaSettings -Name Modules'
                    UnavailableItems = @()
                }
            )
        }

        $Result = @($Health | Get-O365InternalApiFinding -IncludeHealthy)

        $Result.Count | Should -Be 1
        $Result[0].ComponentStatus | Should -Be 'Healthy'
        $Result[0].ComponentElapsedMilliseconds | Should -Be 37
        $Result[0].SuggestedCommand | Should -Be 'Get-O365OrgVivaSettings -Name Modules'
    }
}
