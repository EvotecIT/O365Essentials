Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365SearchIntelligenceAdvanced' {
    It 'uses the configuration settings endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/?' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }
        Get-O365SearchIntelligenceAdvanced -Name ConfigurationSettings
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/searchadminapi/ConfigurationSettings'
        } -Exactly 1
    }

    It 'uses POST with body for Qnas' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/?' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }
        Get-O365SearchIntelligenceAdvanced -Name Qnas -QnasServiceType 'Bing' -QnasFilter 'Published'
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/searchadminapi/Qnas' -and
            $Method -eq 'POST' -and
            $ContentType -eq 'application/json' -and
            $Body.ServiceType -eq 'Bing' -and
            $Body.Filter -eq 'Published' -and
            $QuietOnError
        } -Exactly 1
    }

    It 'uses POST with array body for first run experience' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/?' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365SearchIntelligenceAdvanced -Name FirstRunExperience

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/searchadminapi/firstrunexperience/get' -and
            $Method -eq 'POST' -and
            $ContentType -eq 'application/json' -and
            $Body.Count -eq 5 -and
            $Body[0] -eq 'SearchHomepageBannerFirstTime'
        } -Exactly 1
    }

    It 'builds the News bundle' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/?' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }
        $Result = Get-O365SearchIntelligenceAdvanced -Name News
        $Result.NewsOptions.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/searchadminapi/news/options/Bing'
        $Result.NewsIndustry.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/searchadminapi/news/industry/Bing'
        $Result.NewsMsbEnabled.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/searchadminapi/news/msbenabled/Bing'
    }

    It 'returns a placeholder when configuration settings are unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/?' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365SearchIntelligenceAdvanced -Name ConfigurationSettings

        $Result.Name | Should -Be 'ConfigurationSettings'
        $Result.Reason | Should -Be 'PortalSessionRequired'
        $Result.DataBacked | Should -BeFalse
    }

    It 'treats Qnas as optional when unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/?' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365SearchIntelligenceAdvanced -Name Qnas

        $Result.Name | Should -Be 'Qnas'
        $Result.Reason | Should -Be 'PortalSessionRequired'
        $Result.IsOptional | Should -BeTrue
        $Result.Description | Should -Match 'portal session'
    }

    It 'uses tenant-specific reason when portal session context is available' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/?' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365SearchIntelligenceAdvanced -Headers @{ AjaxSessionKey = 'ajax-key' } -Name ConfigurationSettings

        $Result.Reason | Should -Be 'TenantSpecific'
    }

    It 'prefers portal session replay when portal session metadata is available' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/?'; AjaxSessionKey = 'ajax-key'; 'x-portal-routekey' = 'weu' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365SearchIntelligenceAdvanced -Headers @{ AjaxSessionKey = 'ajax-key'; PortalRouteKey = 'weu'; PortalWebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new() } -Name ConfigurationSettings

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/searchadminapi/ConfigurationSettings' -and
            $UsePortalSession -and
            $AdditionalHeaders.AjaxSessionKey -eq 'ajax-key' -and
            $AdditionalHeaders['x-portal-routekey'] -eq 'weu'
        } -Exactly 1
    }

    It 'falls back to configuration settings when configurations is unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/?' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            if ($Uri -eq 'https://admin.cloud.microsoft/admin/api/searchadminapi/ConfigurationSettings') {
                return [pscustomobject]@{ Uri = $Uri; Source = 'fallback' }
            }
        }

        $Result = Get-O365SearchIntelligenceAdvanced -Name Configurations

        $Result.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/searchadminapi/ConfigurationSettings'
        $Result.FallbackUsed | Should -BeTrue
        $Result.RequestedName | Should -Be 'Configurations'
        $Result.FallbackName | Should -Be 'ConfigurationSettings'
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/searchadminapi/configurations'
        } -Exactly 0
    }
}
