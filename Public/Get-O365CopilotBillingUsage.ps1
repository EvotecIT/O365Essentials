function Get-O365CopilotBillingUsage {
    <#
    .SYNOPSIS
    Retrieves Copilot billing and usage data from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal Copilot billing and usage payloads used by the billing policies,
    pay-as-you-go services, billing accounts, and high-usage users experiences.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which Copilot billing and usage payload group to return.

    .EXAMPLE
    Get-O365CopilotBillingUsage

    .EXAMPLE
    Get-O365CopilotBillingUsage -Name BillingPolicies
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('All', 'AzureSubscriptions', 'BillingAccounts', 'BillingPolicies', 'BillingPolicyBudgets', 'HighUsageUsers', 'PayAsYouGoServices')][string] $Name = 'All'
    )

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context Copilot

    function Get-CopilotBillingLeaf {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $Uri
        )

        Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders
    }

    function Get-CopilotSafeResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            $Result = & $ScriptBlock
            if ($null -eq $Result) {
                New-O365UnavailableResult -Name $ResultName -Area 'Copilot billing and usage section' -Description 'The Copilot billing and usage section did not return a usable payload.'
            } else {
                $Result
            }
        } catch {
            New-O365UnavailableResult -Name $ResultName -Area 'Copilot billing and usage section' -Description 'The Copilot billing and usage section did not return a usable payload.' -ErrorMessage $_.Exception.Message
        }
    }

    switch ($Name) {
        'All' {
            [PSCustomObject] @{
                BillingPolicies   = Get-O365CopilotBillingUsage -Headers $Headers -Name BillingPolicies
                PayAsYouGoServices = Get-O365CopilotBillingUsage -Headers $Headers -Name PayAsYouGoServices
                HighUsageUsers    = Get-O365CopilotBillingUsage -Headers $Headers -Name HighUsageUsers
                BillingAccounts   = Get-O365CopilotBillingUsage -Headers $Headers -Name BillingAccounts
                AzureSubscriptions = Get-O365CopilotBillingUsage -Headers $Headers -Name AzureSubscriptions
            }
            return
        }
        'BillingPolicies' {
            [PSCustomObject] @{
                Policies           = Get-CopilotBillingLeaf -Uri 'https://admin.microsoft.com/_api/v2.1/billingPolicies'
                PolicyBudgets      = Get-O365CopilotBillingUsage -Headers $Headers -Name BillingPolicyBudgets
                BillingAccounts    = Get-O365CopilotBillingUsage -Headers $Headers -Name BillingAccounts
                AzureSubscriptions = Get-O365CopilotBillingUsage -Headers $Headers -Name AzureSubscriptions
            }
            return
        }
        'BillingPolicyBudgets' {
            Get-CopilotSafeResult -ResultName 'BillingPolicyBudgets' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.microsoft.com/_api/v2.1/billingPolicies?budgets=true' }
            return
        }
        'BillingAccounts' {
            [PSCustomObject] @{
                ShellBillingAccounts = Get-CopilotSafeResult -ResultName 'ShellBillingAccounts' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.microsoft.com/admin/api/tenant/billingAccountsWithShell' }
                ArmBillingAccounts   = Get-CopilotSafeResult -ResultName 'ArmBillingAccounts' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.microsoft.com/fd/arm/providers/Microsoft.Billing/billingAccounts?api-version=2020-05-01' }
            }
            return
        }
        'AzureSubscriptions' {
            Get-CopilotSafeResult -ResultName 'AzureSubscriptions' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.microsoft.com/admin/api/tenant/azureSubscriptions' }
            return
        }
        'PayAsYouGoServices' {
            [PSCustomObject] @{
                Policies          = Get-CopilotSafeResult -ResultName 'Policies' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.microsoft.com/_api/v2.1/billingPolicies' }
                CopilotChatPolicy = Get-CopilotSafeResult -ResultName 'CopilotChatPolicy' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.microsoft.com/_api/v2.1/billingPolicies?feature=M365CopilotChat' }
            }
            return
        }
        'HighUsageUsers' {
            [PSCustomObject] @{
                Policies   = Get-CopilotSafeResult -ResultName 'Policies' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.microsoft.com/_api/v2.1/billingPolicies' }
                DataBacked = $false
                Description = 'The High-usage users tab shows a prerequisite message until at least one Copilot billing policy is connected. No separate high-usage user feed was requested by the current tenant state.'
            }
            return
        }
    }
}
