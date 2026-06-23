function Get-O365CopilotBillingUsage {
    <#
    .SYNOPSIS
    Retrieves Copilot billing and usage data from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal Copilot billing and usage payloads used by the billing policies,
    pay-as-you-go services, billing accounts, and high-usage users experiences.

    These routes are especially tenant- and portal-sensitive, so the cmdlet prefers
    admin.cloud.microsoft portal replay when session metadata is available and otherwise
    returns structured unavailable results that clearly distinguish portal/session
    requirements from ordinary read failures.

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

    $RequestHeaders = if ($Headers) { $Headers } else { Connect-O365Admin }
    $AdditionalHeaders = Get-O365PortalContextHeaders -Context CopilotBilling -PortalHost 'https://admin.cloud.microsoft' -AjaxSessionKey $RequestHeaders.AjaxSessionKey -PortalRouteKey $RequestHeaders.PortalRouteKey
    $HasPortalSessionContext = $false
    if ($RequestHeaders) {
        if ($RequestHeaders.Contains('AjaxSessionKey') -and -not [string]::IsNullOrWhiteSpace($RequestHeaders['AjaxSessionKey'])) {
            $HasPortalSessionContext = $true
        }
        elseif ($RequestHeaders.Contains('PortalWebSession') -and $null -ne $RequestHeaders['PortalWebSession']) {
            $HasPortalSessionContext = $true
        }
    }

    switch ($Name) {
        'All' {
            [PSCustomObject] @{
                BillingPolicies    = Get-O365CopilotBillingUsage -Headers $Headers -Name BillingPolicies
                PayAsYouGoServices = Get-O365CopilotBillingUsage -Headers $Headers -Name PayAsYouGoServices
                HighUsageUsers     = Get-O365CopilotBillingUsage -Headers $Headers -Name HighUsageUsers
                BillingAccounts    = Get-O365CopilotBillingUsage -Headers $Headers -Name BillingAccounts
                AzureSubscriptions = Get-O365CopilotBillingUsage -Headers $Headers -Name AzureSubscriptions
            }
            return
        }
        'BillingPolicies' {
            [PSCustomObject] @{
                Policies           = Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies' -AdditionalLeafHeaders (Get-CopilotSPOHeaders)
                PolicyBudgets      = Get-O365CopilotBillingUsage -Headers $Headers -Name BillingPolicyBudgets
                BillingAccounts    = Get-O365CopilotBillingUsage -Headers $Headers -Name BillingAccounts
                AzureSubscriptions = Get-O365CopilotBillingUsage -Headers $Headers -Name AzureSubscriptions
            }
            return
        }
        'BillingPolicyBudgets' {
            Invoke-O365SectionSafeResult -Section CopilotBilling -ResultName 'BillingPolicyBudgets' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies?budgets=true' -AdditionalLeafHeaders (Get-CopilotSPOHeaders) }
            return
        }
        'BillingAccounts' {
            [PSCustomObject] @{
                ShellBillingAccounts = Invoke-O365SectionSafeResult -Section CopilotBilling -ResultName 'ShellBillingAccounts' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/admin/api/tenant/billingAccountsWithShell' }
                ArmBillingAccounts   = Invoke-O365SectionSafeResult -Section CopilotBilling -ResultName 'ArmBillingAccounts' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/fd/arm/providers/Microsoft.Billing/billingAccounts?api-version=2020-05-01' }
            }
            return
        }
        'AzureSubscriptions' {
            Invoke-O365SectionSafeResult -Section CopilotBilling -ResultName 'AzureSubscriptions' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/admin/api/tenant/azureSubscriptions' }
            return
        }
        'PayAsYouGoServices' {
            [PSCustomObject] @{
                Policies          = Invoke-O365SectionSafeResult -Section CopilotBilling -ResultName 'Policies' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies' -AdditionalLeafHeaders (Get-CopilotSPOHeaders) }
                CopilotChatPolicy = Invoke-O365SectionSafeResult -Section CopilotBilling -ResultName 'CopilotChatPolicy' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies?feature=M365CopilotChat' -AdditionalLeafHeaders (Get-CopilotSPOHeaders) }
            }
            return
        }
        'HighUsageUsers' {
            [PSCustomObject] @{
                Policies    = Invoke-O365SectionSafeResult -Section CopilotBilling -ResultName 'Policies' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies' -AdditionalLeafHeaders (Get-CopilotSPOHeaders) }
                DataBacked  = $false
                Description = 'The High-usage users tab shows a prerequisite message until at least one Copilot billing policy is connected. No separate high-usage user feed was requested by the current tenant state.'
            }
            return
        }
    }
}
