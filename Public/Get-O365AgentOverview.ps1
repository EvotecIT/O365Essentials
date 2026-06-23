function Get-O365AgentOverview {
    <#
    .SYNOPSIS
    Retrieves Agents overview data from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal Agents overview payloads such as inventory, risky agents, usage,
    offer recommendations, and top-agent metrics.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which Agents overview payload to return.

    .EXAMPLE
    Get-O365AgentOverview

    .EXAMPLE
    Get-O365AgentOverview -Name Summary
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('ActionableApps', 'AgentInsights', 'Agents', 'All', 'FrontierAccess', 'OfferRecommendations', 'Products', 'RiskyAgents', 'Summary', 'TopAgentsByDailyActiveUsers', 'UsageDailyMetrics', 'UsageMetrics', 'UsageWoWMetrics')][string] $Name = 'All'
    )

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context Agents -PortalHost 'https://admin.cloud.microsoft' -AjaxSessionKey $Headers.AjaxSessionKey -PortalRouteKey $Headers.PortalRouteKey
    $UsePortalSession = $false
    if ($Headers) {
        if ($Headers.Contains('AjaxSessionKey') -and -not [string]::IsNullOrWhiteSpace($Headers['AjaxSessionKey'])) {
            $UsePortalSession = $true
        }
        elseif ($Headers.Contains('PortalWebSession') -and $null -ne $Headers['PortalWebSession']) {
            $UsePortalSession = $true
        }
    }

    if ($Name -eq 'All') {
        [PSCustomObject] @{
            Summary                     = Get-O365AgentOverview -Headers $Headers -Name Summary
            Products                    = Get-O365AgentOverview -Headers $Headers -Name Products
            OfferRecommendations        = Get-O365AgentOverview -Headers $Headers -Name OfferRecommendations
            UsageMetrics                = Get-O365AgentOverview -Headers $Headers -Name UsageMetrics
            UsageWoWMetrics             = Get-O365AgentOverview -Headers $Headers -Name UsageWoWMetrics
            UsageDailyMetrics           = Get-O365AgentOverview -Headers $Headers -Name UsageDailyMetrics
            TopAgentsByDailyActiveUsers = Get-O365AgentOverview -Headers $Headers -Name TopAgentsByDailyActiveUsers
            Agents                      = Get-O365AgentOverview -Headers $Headers -Name Agents
            ActionableApps              = Get-O365AgentOverview -Headers $Headers -Name ActionableApps
            AgentInsights               = Get-O365AgentOverview -Headers $Headers -Name AgentInsights
            FrontierAccess              = Get-O365AgentOverview -Headers $Headers -Name FrontierAccess
            RiskyAgents                 = Get-O365AgentOverview -Headers $Headers -Name RiskyAgents
        }
        return
    }

    switch ($Name) {
        'Summary' {
            Get-AgentSummary
            return
        }
        'OfferRecommendations' {
            [PSCustomObject] @{
                Offer48 = Get-AgentOfferRecommendation -ResultName 'Offer48' -Uri 'https://admin.cloud.microsoft/admin/api/offerrec/offer/48'
                Offer49 = Get-AgentOfferRecommendation -ResultName 'Offer49' -Uri 'https://admin.cloud.microsoft/admin/api/offerrec/offer/49'
            }
            return
        }
        'Products' {
            Invoke-O365SectionSafeResult -Section AgentsOverview -ResultName 'Products' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/admin/api/users/products' }
            return
        }
        'UsageMetrics' {
            Invoke-O365SectionSafeResult -Section AgentsOverview -ResultName 'UsageMetrics' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityname=getCopilotAgentActiveUserRL30Metrics&pagesize=100' }
            return
        }
        'UsageWoWMetrics' {
            Invoke-O365SectionSafeResult -Section AgentsOverview -ResultName 'UsageWoWMetrics' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityname=getCopilotAgentActiveUserRL30WoWMetrics&pagesize=100' }
            return
        }
        'UsageDailyMetrics' {
            Invoke-O365SectionSafeResult -Section AgentsOverview -ResultName 'UsageDailyMetrics' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityname=getCopilotAgentActiveUserRL30DailyMetrics&pagesize=100' }
            return
        }
        'TopAgentsByDailyActiveUsers' {
            Invoke-O365SectionSafeResult -Section AgentsOverview -ResultName 'TopAgentsByDailyActiveUsers' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityname=getCopilotTenantTopAgentsByDAU&pagesize=100' }
            return
        }
        'Agents' {
            Invoke-O365SectionSafeResult -Section AgentsOverview -ResultName 'Agents' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/fd/addins/api/agents?workloads=SharedAgent&scopes=Shared&limit=200&creatorId=none' -UsageOrigin 'AgentsOverview' }
            return
        }
        'ActionableApps' {
            Invoke-O365SectionSafeResult -Section AgentsOverview -ResultName 'ActionableApps' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/fd/addins/api/actionableApps?workloads=MetaOS%2CSharedAgent&limit=200' -UsageOrigin 'CopilotSettings' }
            return
        }
        'AgentInsights' {
            Invoke-O365SectionSafeResult -Section AgentsOverview -ResultName 'AgentInsights' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/fd/addins/api/apps/insight?workload=SharedAgent&entraScopes=EntraAgentBlueprintSP,EntraAgentPVA,EntraAgentIdentity' -UsageOrigin 'AgentsOverview' }
            return
        }
        'FrontierAccess' {
            Invoke-O365SectionSafeResult -Section AgentsOverview -ResultName 'FrontierAccess' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/admin/api/settings/company/frontier/access' }
            return
        }
        'RiskyAgents' {
            $Result = Invoke-O365SectionSafeResult -Section AgentsOverview -ResultName 'RiskyAgents' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/admin/api/agentusers/metrics/agents/risky?maxCount=3' -QuietOnError }
            if (Test-O365UnavailableResult -InputObject $Result) {
                $Fallback = Get-AgentRiskyAgentsFallback
                if ($Fallback) {
                    $Fallback
                    return
                }
            }
            $Result
            return
        }
    }
}
