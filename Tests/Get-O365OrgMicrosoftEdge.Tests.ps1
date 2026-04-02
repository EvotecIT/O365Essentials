Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365OrgMicrosoftEdge' {
    It 'uses the device count endpoint and converts it to a summary' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            [pscustomobject] @{
                '@odata.count' = 42
                value = @([pscustomobject] @{ id = 'device-1' })
            }
        }

        $Result = Get-O365OrgMicrosoftEdge -Name DeviceCount

        $Result.Count | Should -Be 42
        @($Result.Sample).Count | Should -Be 1
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/fd/MSGraph/v1.0/devices?$count=true&$top=1' -and $AdditionalHeaders['ConsistencyLevel'] -eq 'eventual'
        } -Exactly 1
    }

    It 'uses the extension policies endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365OrgMicrosoftEdge -Name ExtensionPolicies

        $Result.Uri | Should -Be 'https://admin.cloud.microsoft/fd/edgeenterpriseextensionsmanagement/api/policies'
    }

    It 'returns grouped data for All' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Get-O365OrgMicrosoftEdgeSiteLists -MockWith { [pscustomobject] @{ Name = 'SiteLists' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            if ($Uri -like '*devices*') {
                [pscustomobject] @{ '@odata.count' = 4; value = @() }
            } else {
                [pscustomobject] @{ Uri = $Uri }
            }
        }

        $Result = Get-O365OrgMicrosoftEdge

        $Result.ConfigurationPolicies.Uri | Should -Be 'https://admin.cloud.microsoft/fd/OfficePolicyAdmin/v1.0/edge/policies'
        $Result.DeviceCount.Count | Should -Be 4
        $Result.SiteLists.Name | Should -Be 'SiteLists'
    }

    It 'returns a placeholder when extension feedback is unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { throw 'missing feedback route' }

        $Result = Get-O365OrgMicrosoftEdge -Name ExtensionFeedback

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/fd/edgeenterpriseextensionsmanagement/api/extensions/extensionFeedback' -and
            $QuietOnError
        } -Exactly 1
        $Result.Name | Should -Be 'ExtensionFeedback'
        $Result.DataBacked | Should -BeFalse
        $Result.IsOptional | Should -BeTrue
    }

    It 'treats empty configuration policies responses as healthy empty arrays' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365OrgMicrosoftEdge -Name ConfigurationPolicies

        $null -eq $Result | Should -BeFalse
        $Result -is [array] | Should -BeTrue
        $Result.Count | Should -Be 0
    }

    It 'treats empty extension feedback responses as healthy empty arrays' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365OrgMicrosoftEdge -Name ExtensionFeedback

        $null -eq $Result | Should -BeFalse
        $Result -is [array] | Should -BeTrue
        $Result.Count | Should -Be 0
    }

    It 'prefers portal session replay when portal session metadata is available' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/'; AjaxSessionKey = 'ajax-key'; 'x-portal-routekey' = 'weu' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            [pscustomobject] @{
                '@odata.count' = 42
                value = @()
            }
        }

        Get-O365OrgMicrosoftEdge -Headers @{ AjaxSessionKey = 'ajax-key'; PortalRouteKey = 'weu'; PortalWebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new() } -Name DeviceCount | Out-Null

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/fd/MSGraph/v1.0/devices?$count=true&$top=1' -and
            $UsePortalSession -and
            $AdditionalHeaders.AjaxSessionKey -eq 'ajax-key' -and
            $AdditionalHeaders['x-portal-routekey'] -eq 'weu'
        } -Exactly 1
    }
}
