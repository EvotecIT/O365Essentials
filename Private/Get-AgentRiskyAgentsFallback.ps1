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
