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
    $AdditionalHeaders = Get-O365PortalContextHeaders -Context Copilot -PortalHost 'https://admin.cloud.microsoft' -AjaxSessionKey $RequestHeaders.AjaxSessionKey -PortalRouteKey $RequestHeaders.PortalRouteKey
    $HasPortalSessionContext = $false
    if ($RequestHeaders) {
        if ($RequestHeaders.Contains('AjaxSessionKey') -and -not [string]::IsNullOrWhiteSpace($RequestHeaders['AjaxSessionKey'])) {
            $HasPortalSessionContext = $true
        } elseif ($RequestHeaders.Contains('PortalWebSession') -and $null -ne $RequestHeaders['PortalWebSession']) {
            $HasPortalSessionContext = $true
        }
    }

    function Get-CopilotBillingLeaf {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $Uri
        )

        $Splat = @{
            Uri               = $Uri
            Headers           = $RequestHeaders
            Method            = 'GET'
            AdditionalHeaders = $AdditionalHeaders
        }
        if ($HasPortalSessionContext -and $Uri -like 'https://admin.cloud.microsoft/*') {
            $Splat['UsePortalSession'] = $true
        }
        $Splat['QuietOnError'] = $true

        Invoke-O365Admin @Splat
    }

    function New-CopilotBillingUnavailableResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [string] $ErrorMessage
        )

        $Reason = 'TenantSpecific'
        $Description = 'The Copilot billing and usage section did not return a usable payload.'
        $SuggestedAction = 'Verify the tenant has Copilot billing features enabled, the signed-in account has the required admin role, and the route is available in the current portal experience.'

        if (-not $HasPortalSessionContext -or $ErrorMessage -match '\b440\b') {
            $Reason = 'PortalSessionRequired'
            $Description = 'The Copilot billing and usage section appears to require an authenticated admin.cloud.microsoft portal session with AjaxSessionKey or portal cookies in addition to bearer-token auth.'
            $SuggestedAction = 'Replay the request through a validated admin.cloud.microsoft portal session or supply portal session state before retrying this Copilot surface.'
        }

        New-O365UnavailableResult -Name $ResultName -Area 'Copilot billing and usage section' -Description $Description -Reason $Reason -ErrorMessage $ErrorMessage -SuggestedAction $SuggestedAction
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
                New-CopilotBillingUnavailableResult -ResultName $ResultName
            } else {
                $Result
            }
        } catch {
            New-CopilotBillingUnavailableResult -ResultName $ResultName -ErrorMessage $_.Exception.Message
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
                Policies           = Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies'
                PolicyBudgets      = Get-O365CopilotBillingUsage -Headers $Headers -Name BillingPolicyBudgets
                BillingAccounts    = Get-O365CopilotBillingUsage -Headers $Headers -Name BillingAccounts
                AzureSubscriptions = Get-O365CopilotBillingUsage -Headers $Headers -Name AzureSubscriptions
            }
            return
        }
        'BillingPolicyBudgets' {
            Get-CopilotSafeResult -ResultName 'BillingPolicyBudgets' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies?budgets=true' }
            return
        }
        'BillingAccounts' {
            [PSCustomObject] @{
                ShellBillingAccounts = Get-CopilotSafeResult -ResultName 'ShellBillingAccounts' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/admin/api/tenant/billingAccountsWithShell' }
                ArmBillingAccounts   = Get-CopilotSafeResult -ResultName 'ArmBillingAccounts' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/fd/arm/providers/Microsoft.Billing/billingAccounts?api-version=2020-05-01' }
            }
            return
        }
        'AzureSubscriptions' {
            Get-CopilotSafeResult -ResultName 'AzureSubscriptions' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/admin/api/tenant/azureSubscriptions' }
            return
        }
        'PayAsYouGoServices' {
            [PSCustomObject] @{
                Policies          = Get-CopilotSafeResult -ResultName 'Policies' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies' }
                CopilotChatPolicy = Get-CopilotSafeResult -ResultName 'CopilotChatPolicy' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies?feature=M365CopilotChat' }
            }
            return
        }
        'HighUsageUsers' {
            [PSCustomObject] @{
                Policies   = Get-CopilotSafeResult -ResultName 'Policies' -ScriptBlock { Get-CopilotBillingLeaf -Uri 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies' }
                DataBacked = $false
                Description = 'The High-usage users tab shows a prerequisite message until at least one Copilot billing policy is connected. No separate high-usage user feed was requested by the current tenant state.'
            }
            return
        }
    }
}
