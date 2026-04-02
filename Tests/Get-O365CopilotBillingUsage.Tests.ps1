Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365CopilotBillingUsage' {
    It 'uses the billing policy budgets endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365CopilotBillingUsage -Name BillingPolicyBudgets

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.microsoft.com/_api/v2.1/billingPolicies?budgets=true'
        } -Exactly 1
    }

    It 'builds the billing policies bundle' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365CopilotBillingUsage -Name BillingPolicies

        $Result.Policies.Uri | Should -Be 'https://admin.microsoft.com/_api/v2.1/billingPolicies'
        $Result.PolicyBudgets.Uri | Should -Be 'https://admin.microsoft.com/_api/v2.1/billingPolicies?budgets=true'
        $Result.AzureSubscriptions.Uri | Should -Be 'https://admin.microsoft.com/admin/api/tenant/azureSubscriptions'
    }

    It 'returns the high usage users placeholder' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365CopilotBillingUsage -Name HighUsageUsers

        $Result.DataBacked | Should -BeFalse
        $Result.Policies.Uri | Should -Be 'https://admin.microsoft.com/_api/v2.1/billingPolicies'
        $Result.Description | Should -Match 'prerequisite message'
    }

    It 'returns a placeholder when an ARM billing route returns no data' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            if ($Uri -eq 'https://admin.microsoft.com/fd/arm/providers/Microsoft.Billing/billingAccounts?api-version=2020-05-01') {
                $null
            } else {
                [pscustomobject] @{ Uri = $Uri }
            }
        }

        $Result = Get-O365CopilotBillingUsage -Name BillingAccounts

        $Result.ShellBillingAccounts.Uri | Should -Be 'https://admin.microsoft.com/admin/api/tenant/billingAccountsWithShell'
        $Result.ArmBillingAccounts.Name | Should -Be 'ArmBillingAccounts'
        $Result.ArmBillingAccounts.DataBacked | Should -BeFalse
    }
}
