function Get-SuggestedCommand {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $AreaName,
        [Parameter(Mandatory)][string] $ComponentName
    )

    switch ($AreaName) {
        'TenantRelationship' { return "Get-O365TenantRelationship -Name $ComponentName" }
        'People' { return "Get-O365OrgPeopleSettings -Name $ComponentName" }
        'IntegratedApps' { return "Get-O365OrgIntegratedApps -Name $ComponentName" }
        'BrandCenter' { return "Get-O365OrgBrandCenter -Name $ComponentName" }
        'MicrosoftEdge' {
            if ($ComponentName -in 'SiteLists', 'Notifications') {
                return "Get-O365OrgMicrosoftEdgeSiteLists -Name $ComponentName"
            }
            return "Get-O365OrgMicrosoftEdge -Name $ComponentName"
        }
        'Viva' { return "Get-O365OrgVivaSettings -Name $ComponentName" }
        'Agents' {
            switch ($ComponentName) {
                'Settings' { return 'Get-O365AgentSettings -Name All' }
                'Tools' { return 'Get-O365AgentTools -Name All' }
                'Overview' { return 'Get-O365AgentOverview -Name All' }
                'RiskyAgents' { return 'Get-O365AgentOverview -Name RiskyAgents' }
            }
        }
        'Copilot' {
            switch ($ComponentName) {
                'Overview' { return 'Get-O365CopilotOverview -Name Overview' }
                'Recommendations' { return 'Get-O365CopilotSettings -Name Recommendations' }
                'ConnectorsSummary' { return 'Get-O365CopilotConnectors -Name Summary' }
                'BillingPolicies' { return 'Get-O365CopilotBillingUsage -Name BillingPolicies' }
                'Settings' { return 'Get-O365CopilotSettings -Name All' }
                'Connectors' { return 'Get-O365CopilotConnectors -Name All' }
                'BillingUsage' { return 'Get-O365CopilotBillingUsage -Name All' }
            }
        }
        'Search' {
            if ($ComponentName -eq 'Result') {
                return 'Get-O365SearchIntelligenceAdvanced -Name All'
            }
            return "Get-O365SearchIntelligenceAdvanced -Name $ComponentName"
        }
        'Backup' {
            if ($ComponentName -eq 'Result') {
                return 'Get-O365OrgBackup -Name All'
            }
            return "Get-O365OrgBackup -Name $ComponentName"
        }
        'ContentUnderstanding' {
            if ($ComponentName -eq 'Result') {
                return 'Get-O365ContentUnderstanding -Name All'
            }
            return "Get-O365ContentUnderstanding -Name $ComponentName"
        }
        'PayAsYouGo' {
            if ($ComponentName -eq 'Result') {
                return 'Get-O365PayAsYouGoService -Name All'
            }
            return "Get-O365PayAsYouGoService -Name $ComponentName"
        }
    }

    $null
}
