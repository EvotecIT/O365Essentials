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
        } elseif ($Headers.Contains('PortalWebSession') -and $null -ne $Headers['PortalWebSession']) {
            $UsePortalSession = $true
        }
    }

    function Invoke-AgentOverviewRequest {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $Uri,
            [string] $UsageOrigin,
            [switch] $QuietOnError
        )

        $LeafHeaders = [ordered] @{}
        foreach ($Key in $AdditionalHeaders.Keys) {
            $LeafHeaders[$Key] = $AdditionalHeaders[$Key]
        }
        $LeafHeaders['x-adminapp-request'] = '/agents/overview'

        if ($Uri -like 'https://admin.cloud.microsoft/fd/addins/api/*') {
            $LeafHeaders['x-admin-portal-flight'] = 'UDShowTeamsAppInAvailableList,UDAddInToMosUpdateEnabled,UDAIAdminEnabled'
            if (-not [string]::IsNullOrWhiteSpace($UsageOrigin)) {
                $LeafHeaders['x-usage-origin'] = $UsageOrigin
            }
        }

        $Splat = @{
            Uri               = $Uri
            Headers           = $Headers
            Method            = 'GET'
            AdditionalHeaders = $LeafHeaders
            UsePortalSession  = $UsePortalSession
        }
        if ($QuietOnError) {
            $Splat['QuietOnError'] = $true
        }
        Invoke-O365Admin @Splat
    }

    function Get-AgentSafeResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            $Result = & $ScriptBlock
            if ($null -eq $Result) {
                New-O365UnavailableResult -Name $ResultName -Area 'Agents overview section' -Description 'The Agents overview section did not return a usable payload.'
            } else {
                $Result
            }
        } catch {
            New-O365UnavailableResult -Name $ResultName -Area 'Agents overview section' -Description 'The Agents overview section did not return a usable payload.' -ErrorMessage $_.Exception.Message
        }
    }

    function Get-AgentOfferRecommendation {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][string] $Uri
        )

        try {
            $Result = Invoke-AgentOverviewRequest -Uri $Uri
            [PSCustomObject] @{
                Name       = $ResultName
                HasOffer   = $null -ne $Result
                NoData     = $null -eq $Result
                DataBacked = $true
                Result     = $Result
            }
        } catch {
            New-O365UnavailableResult -Name $ResultName -Area 'Agents overview section' -Description 'The Agents overview section did not return a usable payload.' -ErrorMessage $_.Exception.Message
        }
    }

    function Get-AgentSummary {
        $AgentInsights = Get-O365AgentOverview -Headers $Headers -Name AgentInsights
        $RiskyAgents = Get-O365AgentOverview -Headers $Headers -Name RiskyAgents

        $Counts = $null
        $Metrics = $null
        if ($AgentInsights -and $AgentInsights.data -and $AgentInsights.data.titlesInsight -and $AgentInsights.data.titlesInsight.Counts) {
            $Counts = $AgentInsights.data.titlesInsight.Counts
            if ($Counts.AgentAggregatedMetricsResponse) {
                $Metrics = $Counts.AgentAggregatedMetricsResponse
            }
        }

        [PSCustomObject] @{
            TotalAgents          = if ($Metrics -and $Metrics.summary) { $Metrics.summary.totalAgents } else { $null }
            TotalAgentsLastWeek  = if ($Metrics -and $Metrics.summary) { $Metrics.summary.totalAgentsLastWeek } else { $null }
            BlockedAgents        = if ($Metrics -and $Metrics.summary) { $Metrics.summary.blockedAgents } else { $null }
            TotalRiskyAgentCount = if ($RiskyAgents.totalRiskyAgentCount) { $RiskyAgents.totalRiskyAgentCount } elseif ($Metrics -and $Metrics.summary) { $Metrics.summary.totalRiskyAgentCount } else { $null }
            OrphanedAgents       = if ($Counts) { $Counts.OrphanedAgents } else { $null }
            CountsByAppType      = if ($Metrics) { $Metrics.countsByAppType } else { $null }
            CountsByBuilder      = if ($Metrics) { $Metrics.countsByBuilder } else { $null }
            RiskyAgentsDetails   = if ($RiskyAgents.riskyAgentsDetails) { $RiskyAgents.riskyAgentsDetails } else { $null }
            RawAgentInsights     = $AgentInsights
            RawRiskyAgents       = $RiskyAgents
        }
    }

    function Get-AgentRiskyAgentsFallback {
        [cmdletbinding()]
        param()

        $AgentInsights = Get-O365AgentOverview -Headers $Headers -Name AgentInsights
        if (Test-O365UnavailableResult -InputObject $AgentInsights) {
            return $null
        }

        $MetricsSummary = $AgentInsights.data.titlesInsight.Counts.AgentAggregatedMetricsResponse.summary
        if ($null -eq $MetricsSummary -or [string]::IsNullOrWhiteSpace([string] $MetricsSummary.totalRiskyAgentCount)) {
            return $null
        }

        [PSCustomObject] @{
            totalRiskyAgentCount = $MetricsSummary.totalRiskyAgentCount
            riskyAgentsDetails   = @()
            FallbackUsed         = $true
            RequestedName        = 'RiskyAgents'
            FallbackName         = 'AgentInsights'
            RawAgentInsights     = $AgentInsights
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
            Get-AgentSafeResult -ResultName 'Products' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/admin/api/users/products' }
            return
        }
        'UsageMetrics' {
            Get-AgentSafeResult -ResultName 'UsageMetrics' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityname=getCopilotAgentActiveUserRL30Metrics&pagesize=100' }
            return
        }
        'UsageWoWMetrics' {
            Get-AgentSafeResult -ResultName 'UsageWoWMetrics' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityname=getCopilotAgentActiveUserRL30WoWMetrics&pagesize=100' }
            return
        }
        'UsageDailyMetrics' {
            Get-AgentSafeResult -ResultName 'UsageDailyMetrics' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityname=getCopilotAgentActiveUserRL30DailyMetrics&pagesize=100' }
            return
        }
        'TopAgentsByDailyActiveUsers' {
            Get-AgentSafeResult -ResultName 'TopAgentsByDailyActiveUsers' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityname=getCopilotTenantTopAgentsByDAU&pagesize=100' }
            return
        }
        'Agents' {
            Get-AgentSafeResult -ResultName 'Agents' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/fd/addins/api/agents?workloads=SharedAgent&scopes=Shared&limit=200&creatorId=none' -UsageOrigin 'AgentsOverview' }
            return
        }
        'ActionableApps' {
            Get-AgentSafeResult -ResultName 'ActionableApps' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/fd/addins/api/actionableApps?workloads=MetaOS%2CSharedAgent&limit=200' -UsageOrigin 'CopilotSettings' }
            return
        }
        'AgentInsights' {
            Get-AgentSafeResult -ResultName 'AgentInsights' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/fd/addins/api/apps/insight?workload=SharedAgent&entraScopes=EntraAgentBlueprintSP,EntraAgentPVA,EntraAgentIdentity' -UsageOrigin 'AgentsOverview' }
            return
        }
        'FrontierAccess' {
            Get-AgentSafeResult -ResultName 'FrontierAccess' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/admin/api/settings/company/frontier/access' }
            return
        }
        'RiskyAgents' {
            $Result = Get-AgentSafeResult -ResultName 'RiskyAgents' -ScriptBlock { Invoke-AgentOverviewRequest -Uri 'https://admin.cloud.microsoft/admin/api/agentusers/metrics/agents/risky?maxCount=3' -QuietOnError }
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
