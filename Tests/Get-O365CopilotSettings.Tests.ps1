Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365CopilotSettings' {
    BeforeEach {
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { [ordered] @{ Tenant = 'tenant-1234' } }
    }

    It 'uses the recommendations endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365CopilotSettings -Name Recommendations

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/recommendations/m365/ccs'
        } -Times 1 -Exactly
    }

    It 'requests the live CopilotSettings portal context' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365CopilotSettings -Name Recommendations

        Should -Invoke -CommandName Get-O365PortalContextHeaders -ModuleName O365Essentials -ParameterFilter {
            $Context -eq 'CopilotSettings'
        } -Times 1 -Exactly
    }

    It 'uses SPO-flavored headers for the billing policy route' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/'; 'x-ms-mac-target-app' = 'MAC' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365CopilotSettings -Name CopilotChatBillingPolicy

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies?feature=M365CopilotChat' -and
            $AdditionalHeaders['x-ms-mac-target-app'] -eq 'SPO' -and
            $AdditionalHeaders['odata-version'] -eq '4.0' -and
            $AdditionalHeaders['Accept'] -eq 'application/json'
        } -Times 1 -Exactly
    }

    It 'builds the Optimize bundle' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365CopilotSettings -Name Optimize

        $Result.Recommendations.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/recommendations/m365/ccs'
        $Result.CopilotChatBillingPolicy.Uri | Should -Be 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies?feature=M365CopilotChat'
        $Result.AuditEnabled.Uri | Should -Be 'https://admin.cloud.microsoft/fd/purview/apiproxy/adtsch/AuditEnabled'
    }

    It 'uses the tenant-aware Purview for AI setting endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365CopilotSettings -Name PurviewForAISetting

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/fd/purview/apiproxy/di/find/PurviewForAISetting?tenantId=tenant-1234'
        } -Times 1 -Exactly
    }

    It 'returns an unavailable placeholder when a Purview route returns no data' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365CopilotSettings -Name AuditEnabled

        $Result.Name | Should -Be 'AuditEnabled'
        $Result.Reason | Should -Be 'PortalSessionRequired'
        $Result.DataBacked | Should -BeFalse
    }

    It 'reuses tenant information from supplied headers without reconnecting' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365CopilotSettings -Headers @{ Tenant = 'tenant-1234' } -Name Recommendations

        Should -Invoke -CommandName Connect-O365Admin -ModuleName O365Essentials -Times 0 -Exactly
    }
}
