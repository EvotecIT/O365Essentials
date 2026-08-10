Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365CopilotBillingUsage' {
    It 'uses the billing policy budgets endpoint' {
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { [ordered] @{ Tenant = 'tenant-1234' } }
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365CopilotBillingUsage -Name BillingPolicyBudgets

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies?budgets=true'
        } -Times 1 -Exactly
    }

    It 'requests the live CopilotBilling portal context' {
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { [ordered] @{ Tenant = 'tenant-1234' } }
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365CopilotBillingUsage -Name BillingPolicyBudgets

        Should -Invoke -CommandName Get-O365PortalContextHeaders -ModuleName O365Essentials -ParameterFilter {
            $Context -eq 'CopilotBilling'
        } -Times 1 -Exactly
    }

    It 'uses SPO-flavored headers for billing policy routes' {
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { [ordered] @{ Tenant = 'tenant-1234' } }
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/'; 'x-ms-mac-target-app' = 'MAC' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365CopilotBillingUsage -Name BillingPolicyBudgets

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies?budgets=true' -and
            $AdditionalHeaders['x-ms-mac-target-app'] -eq 'SPO' -and
            $AdditionalHeaders['odata-version'] -eq '4.0' -and
            $AdditionalHeaders['Accept'] -eq 'application/json'
        } -Times 1 -Exactly
    }

    It 'builds the billing policies bundle' {
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { [ordered] @{ Tenant = 'tenant-1234' } }
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365CopilotBillingUsage -Name BillingPolicies

        $Result.Policies.Uri | Should -Be 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies'
        $Result.PolicyBudgets.Uri | Should -Be 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies?budgets=true'
        $Result.AzureSubscriptions.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/tenant/azureSubscriptions'
    }

    It 'returns the high usage users placeholder' {
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { [ordered] @{ Tenant = 'tenant-1234' } }
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365CopilotBillingUsage -Name HighUsageUsers

        $Result.DataBacked | Should -BeFalse
        $Result.Policies.Uri | Should -Be 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies'
        $Result.Description | Should -Match 'prerequisite message'
    }

    It 'returns a placeholder when an ARM billing route returns no data' {
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { [ordered] @{ Tenant = 'tenant-1234' } }
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            if ($Uri -eq 'https://admin.cloud.microsoft/fd/arm/providers/Microsoft.Billing/billingAccounts?api-version=2020-05-01') {
                $null
            } else {
                [pscustomobject] @{ Uri = $Uri }
            }
        }

        $Result = Get-O365CopilotBillingUsage -Name BillingAccounts

        $Result.ShellBillingAccounts.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/tenant/billingAccountsWithShell'
        $Result.ArmBillingAccounts.Name | Should -Be 'ArmBillingAccounts'
        $Result.ArmBillingAccounts.Reason | Should -Be 'PortalSessionRequired'
        $Result.ArmBillingAccounts.DataBacked | Should -BeFalse
    }

    It 'reuses portal-capable supplied headers without reconnecting' {
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { [ordered] @{ Tenant = 'tenant-1234' } }
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/'; AjaxSessionKey = 'ajax-key'; 'x-portal-routekey' = 'weu' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365CopilotBillingUsage -Headers @{ Tenant = 'tenant-1234'; AjaxSessionKey = 'ajax-key'; PortalRouteKey = 'weu'; PortalWebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new() } -Name AzureSubscriptions

        Should -Invoke -CommandName Connect-O365Admin -ModuleName O365Essentials -Times 0 -Exactly
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/tenant/azureSubscriptions' -and
            $UsePortalSession
        } -Times 1 -Exactly
    }
}
