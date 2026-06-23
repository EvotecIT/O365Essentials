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
