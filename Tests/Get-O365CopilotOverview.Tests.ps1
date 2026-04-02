Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365CopilotOverview' {
    BeforeEach {
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { [ordered] @{ Tenant = 'tenant-1234' } }
    }

    It 'uses the overview settings endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Get-O365CopilotPin -MockWith { [pscustomobject] @{ enabled = $true } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365CopilotOverview -Name Overview

        $Result.CopilotSettings.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/copilotsettings/settings'
        $Result.PinPolicy.enabled | Should -BeTrue
    }

    It 'builds the About bundle' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Get-O365CopilotPin -MockWith { [pscustomobject] @{ enabled = $true } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365CopilotOverview -Name About

        $Result.Discover.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/copilotsettings/copilot/discover'
        $Result.MarketplaceSeatSize.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/tenant/marketplaceSeatSize'
    }

    It 'builds the Security bundle with tenant-aware Purview endpoints' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365CopilotOverview -Name Security

        $Result.PurviewBootInfo.Uri | Should -Be 'https://admin.cloud.microsoft/fd/purview/api/boot/getNexusBootInfo'
        $Result.PurviewSettings.Uri | Should -Be 'https://admin.cloud.microsoft/fd/purview/apiproxy/di/find/PurviewForAISetting?tenantId=tenant-1234'
        $Result.SensitiveInfoTypes.Uri | Should -Be 'https://admin.cloud.microsoft/fd/purview/apiproxy/di/find/DlpSensitiveInformationType?tenantId=tenant-1234'
    }

    It 'returns a placeholder for unavailable security payloads' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            if ($Uri -eq 'https://admin.cloud.microsoft/fd/purview/api/boot/getNexusBootInfo') {
                $null
            } else {
                [pscustomobject] @{ Uri = $Uri }
            }
        }

        $Result = Get-O365CopilotOverview -Name Security

        $Result.PurviewBootInfo.Name | Should -Be 'PurviewBootInfo'
        $Result.PurviewBootInfo.Reason | Should -Be 'PortalSessionRequired'
        $Result.PurviewBootInfo.DataBacked | Should -BeFalse
        $Result.PurviewSettings.Uri | Should -Be 'https://admin.cloud.microsoft/fd/purview/apiproxy/di/find/PurviewForAISetting?tenantId=tenant-1234'
    }

    It 'reuses tenant information from supplied headers without reconnecting' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Get-O365CopilotPin -MockWith { [pscustomobject] @{ enabled = $true } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        Get-O365CopilotOverview -Headers @{ Tenant = 'tenant-1234' } -Name About

        Assert-MockCalled Connect-O365Admin -ModuleName O365Essentials -Exactly 0
    }
}
