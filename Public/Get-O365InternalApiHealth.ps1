function Get-O365InternalApiHealth {
    <#
    .SYNOPSIS
    Validates high-value internal Microsoft 365 admin surfaces added to O365Essentials.

    .DESCRIPTION
    Runs a grouped health check across the newer internal/admin-center-only cmdlets and
    summarizes which areas returned healthy data, partial data, or structured unavailable
    placeholders. This is intended as a tenant validation helper after connecting with
    Connect-O365Admin.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Area
    Limits validation to one or more areas. Use All to validate the full set.

    .PARAMETER Mode
    Standard keeps the validation lighter and faster. Deep runs the broader grouped
    bundles for Agents, Copilot, Search, Backup, Content Understanding, pay-as-you-go,
    and the newer Edge-facing and Viva admin readers.

    .PARAMETER IncludeResult
    Includes the raw result payload for each validated area.

    .EXAMPLE
    Get-O365InternalApiHealth

    .EXAMPLE
    Get-O365InternalApiHealth -Area Copilot, Agents -Mode Deep

    .EXAMPLE
    Get-O365InternalApiHealth -IncludeResult | Where-Object Status -ne 'Healthy'
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('Agents', 'All', 'Backup', 'BrandCenter', 'ContentUnderstanding', 'Copilot', 'IntegratedApps', 'MicrosoftEdge', 'PayAsYouGo', 'People', 'Search', 'TenantRelationship', 'Viva')][string[]] $Area = @('TenantRelationship', 'People', 'IntegratedApps', 'BrandCenter', 'MicrosoftEdge', 'Viva', 'Agents', 'Copilot', 'Search', 'Backup'),
        [ValidateSet('Standard', 'Deep')][string] $Mode = 'Standard',
        [switch] $IncludeResult
    )

    function Get-HealthComponents {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)] $Result
        )

        if ($null -eq $Result) {
            return @()
        }

        if (Test-O365UnavailableResult -InputObject $Result) {
            return @([PSCustomObject] @{
                    Name  = 'Result'
                    Value = $Result
                    StartedAt = $null
                    CompletedAt = $null
                    ElapsedMilliseconds = $null
                })
        }

        $ComponentTimings = @{}
        if ($Result.PSObject -and $Result.PSObject.Properties.Match('__O365ComponentTimings').Count -gt 0) {
            $ComponentTimings = $Result.__O365ComponentTimings
        }

        if ($Result -is [System.Collections.IDictionary]) {
            return @(
                foreach ($Key in $Result.Keys) {
                    $Timing = if ($ComponentTimings.Contains($Key)) { $ComponentTimings[$Key] } else { $null }
                    [PSCustomObject] @{
                        Name                = [string] $Key
                        Value               = $Result[$Key]
                        StartedAt           = if ($Timing) { $Timing.StartedAt } else { $null }
                        CompletedAt         = if ($Timing) { $Timing.CompletedAt } else { $null }
                        ElapsedMilliseconds = if ($Timing) { $Timing.ElapsedMilliseconds } else { $null }
                    }
                }
            )
        }

        if ($Result -isnot [string] -and $Result -isnot [ValueType] -and $Result.PSObject -and $Result.PSObject.Properties) {
            $Properties = @($Result.PSObject.Properties | Where-Object { $_.MemberType -in 'NoteProperty', 'Property' -and $_.Name -ne '__O365ComponentTimings' })
            if ($Properties.Count -gt 0) {
                return @(
                    foreach ($Property in $Properties) {
                        $Timing = if ($ComponentTimings.Contains($Property.Name)) { $ComponentTimings[$Property.Name] } else { $null }
                        [PSCustomObject] @{
                            Name                = $Property.Name
                            Value               = $Property.Value
                            StartedAt           = if ($Timing) { $Timing.StartedAt } else { $null }
                            CompletedAt         = if ($Timing) { $Timing.CompletedAt } else { $null }
                            ElapsedMilliseconds = if ($Timing) { $Timing.ElapsedMilliseconds } else { $null }
                        }
                    }
                )
            }
        }

        @([PSCustomObject] @{
                Name                = 'Result'
                Value               = $Result
                StartedAt           = $null
                CompletedAt         = $null
                ElapsedMilliseconds = $null
            })
    }

    function Get-ValidationResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $AreaName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            & $ScriptBlock
        } catch {
            New-O365UnavailableResult -Name $AreaName -Area 'Internal API health check' -Description 'The internal API health check could not complete this area.' -Reason 'ValidationError' -SuggestedAction 'Run the area cmdlet directly with -Verbose for route-level details.' -ErrorMessage $_.Exception.Message
        }
    }

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

    function Invoke-HealthLeaf {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $Name,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        $StartedAt = Get-Date
        $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            $Value = & $ScriptBlock
            if ($null -eq $Value) {
                $Value = New-O365UnavailableResult -Name $Name -Area 'Internal API health check component' -Description 'The internal API health check component did not return a usable payload.' -Reason 'ValidationError' -SuggestedAction 'Run the component cmdlet directly with -Verbose for route-level details.'
            }
        } catch {
            $Value = New-O365UnavailableResult -Name $Name -Area 'Internal API health check component' -Description 'The internal API health check component did not return a usable payload.' -Reason 'ValidationError' -SuggestedAction 'Run the component cmdlet directly with -Verbose for route-level details.' -ErrorMessage $_.Exception.Message
        } finally {
            $Stopwatch.Stop()
        }

        [PSCustomObject] @{
            Name                = $Name
            Value               = $Value
            StartedAt           = $StartedAt
            CompletedAt         = Get-Date
            ElapsedMilliseconds = [int] [Math]::Round($Stopwatch.Elapsed.TotalMilliseconds, 0)
        }
    }

    function New-HealthLeafBundle {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][System.Collections.IEnumerable] $Leaves
        )

        $Bundle = [ordered] @{}
        $TimingMap = @{}

        foreach ($Leaf in @($Leaves)) {
            $Bundle[$Leaf.Name] = $Leaf.Value
            $TimingMap[$Leaf.Name] = $Leaf
        }

        $Bundle['__O365ComponentTimings'] = $TimingMap
        [PSCustomObject] $Bundle
    }

    $AllAreas = @('TenantRelationship', 'People', 'IntegratedApps', 'BrandCenter', 'MicrosoftEdge', 'Viva', 'Agents', 'Copilot', 'Search', 'Backup', 'ContentUnderstanding', 'PayAsYouGo')
    $SelectedAreas = if ($Area -contains 'All') { $AllAreas } else { $Area }

    $AreaDefinitions = [ordered] @{
        TenantRelationship = {
            if ($Mode -eq 'Deep') {
                Get-O365TenantRelationship -Headers $Headers -Name All
            } else {
                New-HealthLeafBundle -Leaves @(
                    Invoke-HealthLeaf -Name 'MultiTenantOrganization' -ScriptBlock { Get-O365TenantRelationship -Headers $Headers -Name MultiTenantOrganization }
                    Invoke-HealthLeaf -Name 'OrganizationRelationships' -ScriptBlock { Get-O365TenantRelationship -Headers $Headers -Name OrganizationRelationships }
                    Invoke-HealthLeaf -Name 'Tenants' -ScriptBlock { Get-O365TenantRelationship -Headers $Headers -Name Tenants }
                    Invoke-HealthLeaf -Name 'RemovedTenants' -ScriptBlock { Get-O365TenantRelationship -Headers $Headers -Name RemovedTenants }
                    Invoke-HealthLeaf -Name 'UserSyncAppOutboundDetails' -ScriptBlock { Get-O365TenantRelationship -Headers $Headers -Name UserSyncAppOutboundDetails }
                )
            }
        }
        People = {
            if ($Mode -eq 'Deep') {
                Get-O365OrgPeopleSettings -Headers $Headers -Name All
            } else {
                New-HealthLeafBundle -Leaves @(
                    Invoke-HealthLeaf -Name 'ProfileCardProperties' -ScriptBlock { Get-O365OrgPeopleSettings -Headers $Headers -Name ProfileCardProperties }
                    Invoke-HealthLeaf -Name 'ConnectorProperties' -ScriptBlock { Get-O365OrgPeopleSettings -Headers $Headers -Name ConnectorProperties }
                    Invoke-HealthLeaf -Name 'NamePronunciation' -ScriptBlock { Get-O365OrgPeopleSettings -Headers $Headers -Name NamePronunciation }
                    Invoke-HealthLeaf -Name 'Pronouns' -ScriptBlock { Get-O365OrgPeopleSettings -Headers $Headers -Name Pronouns }
                )
            }
        }
        IntegratedApps = {
            if ($Mode -eq 'Deep') {
                Get-O365OrgIntegratedApps -Headers $Headers -Name All
            } else {
                New-HealthLeafBundle -Leaves @(
                    Invoke-HealthLeaf -Name 'Settings' -ScriptBlock { Get-O365OrgIntegratedApps -Headers $Headers -Name Settings }
                    Invoke-HealthLeaf -Name 'AvailableApps' -ScriptBlock { Get-O365OrgIntegratedApps -Headers $Headers -Name AvailableApps }
                    Invoke-HealthLeaf -Name 'ActionableApps' -ScriptBlock { Get-O365OrgIntegratedApps -Headers $Headers -Name ActionableApps }
                )
            }
        }
        BrandCenter = {
            if ($Mode -eq 'Deep') {
                Get-O365OrgBrandCenter -Headers $Headers -Name All
            } else {
                New-HealthLeafBundle -Leaves @(
                    Invoke-HealthLeaf -Name 'Configuration' -ScriptBlock { Get-O365OrgBrandCenter -Headers $Headers -Name Configuration }
                    Invoke-HealthLeaf -Name 'SiteUrl' -ScriptBlock { Get-O365OrgBrandCenter -Headers $Headers -Name SiteUrl }
                )
            }
        }
        MicrosoftEdge = {
            if ($Mode -eq 'Deep') {
                Get-O365OrgMicrosoftEdge -Headers $Headers -Name All
            } else {
                New-HealthLeafBundle -Leaves @(
                    Invoke-HealthLeaf -Name 'ConfigurationPolicies' -ScriptBlock { Get-O365OrgMicrosoftEdge -Headers $Headers -Name ConfigurationPolicies }
                    Invoke-HealthLeaf -Name 'DeviceCount' -ScriptBlock { Get-O365OrgMicrosoftEdge -Headers $Headers -Name DeviceCount }
                    Invoke-HealthLeaf -Name 'SiteLists' -ScriptBlock { Get-O365OrgMicrosoftEdge -Headers $Headers -Name SiteLists }
                    Invoke-HealthLeaf -Name 'ExtensionFeedback' -ScriptBlock { Get-O365OrgMicrosoftEdge -Headers $Headers -Name ExtensionFeedback }
                )
            }
        }
        Viva = {
            if ($Mode -eq 'Deep') {
                Get-O365OrgVivaSettings -Headers $Headers -Name All
            } else {
                New-HealthLeafBundle -Leaves @(
                    Invoke-HealthLeaf -Name 'Modules' -ScriptBlock { Get-O365OrgVivaSettings -Headers $Headers -Name Modules }
                    Invoke-HealthLeaf -Name 'Roles' -ScriptBlock { Get-O365OrgVivaSettings -Headers $Headers -Name Roles }
                    Invoke-HealthLeaf -Name 'GlintClient' -ScriptBlock { Get-O365OrgVivaSettings -Headers $Headers -Name GlintClient }
                    Invoke-HealthLeaf -Name 'AccountSkus' -ScriptBlock { Get-O365OrgVivaSettings -Headers $Headers -Name AccountSkus }
                )
            }
        }
        Agents = {
            if ($Mode -eq 'Deep') {
                New-HealthLeafBundle -Leaves @(
                    Invoke-HealthLeaf -Name 'Settings' -ScriptBlock { Get-O365AgentSettings -Headers $Headers -Name All }
                    Invoke-HealthLeaf -Name 'Tools' -ScriptBlock { Get-O365AgentTools -Headers $Headers -Name All }
                    Invoke-HealthLeaf -Name 'Overview' -ScriptBlock { Get-O365AgentOverview -Headers $Headers -Name All }
                )
            } else {
                New-HealthLeafBundle -Leaves @(
                    Invoke-HealthLeaf -Name 'Settings' -ScriptBlock { Get-O365AgentSettings -Headers $Headers -Name All }
                    Invoke-HealthLeaf -Name 'Tools' -ScriptBlock { Get-O365AgentTools -Headers $Headers -Name All }
                    Invoke-HealthLeaf -Name 'Overview' -ScriptBlock { Get-O365AgentOverview -Headers $Headers -Name Summary }
                    Invoke-HealthLeaf -Name 'RiskyAgents' -ScriptBlock { Get-O365AgentOverview -Headers $Headers -Name RiskyAgents }
                )
            }
        }
        Copilot = {
            if ($Mode -eq 'Deep') {
                New-HealthLeafBundle -Leaves @(
                    Invoke-HealthLeaf -Name 'Overview' -ScriptBlock { Get-O365CopilotOverview -Headers $Headers -Name All }
                    Invoke-HealthLeaf -Name 'Settings' -ScriptBlock { Get-O365CopilotSettings -Headers $Headers -Name All }
                    Invoke-HealthLeaf -Name 'Connectors' -ScriptBlock { Get-O365CopilotConnectors -Headers $Headers -Name All }
                    Invoke-HealthLeaf -Name 'BillingUsage' -ScriptBlock { Get-O365CopilotBillingUsage -Headers $Headers -Name All }
                )
            } else {
                New-HealthLeafBundle -Leaves @(
                    Invoke-HealthLeaf -Name 'Recommendations' -ScriptBlock { Get-O365CopilotSettings -Headers $Headers -Name Recommendations }
                    Invoke-HealthLeaf -Name 'ConnectorsSummary' -ScriptBlock { Get-O365CopilotConnectors -Headers $Headers -Name Summary }
                )
            }
        }
        Search = {
            if ($Mode -eq 'Deep') {
                Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name All
            } else {
                New-HealthLeafBundle -Leaves @(
                    Invoke-HealthLeaf -Name 'ConfigurationSettings' -ScriptBlock { Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name ConfigurationSettings }
                    Invoke-HealthLeaf -Name 'Qnas' -ScriptBlock { Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name Qnas }
                    Invoke-HealthLeaf -Name 'UdtConnectorsSummary' -ScriptBlock { Get-O365SearchIntelligenceAdvanced -Headers $Headers -Name UdtConnectorsSummary }
                )
            }
        }
        Backup = {
            if ($Mode -eq 'Deep') {
                Get-O365OrgBackup -Headers $Headers -Name All
            } else {
                New-HealthLeafBundle -Leaves @(
                    Invoke-HealthLeaf -Name 'BillingFeature' -ScriptBlock { Get-O365OrgBackup -Headers $Headers -Name BillingFeature }
                    Invoke-HealthLeaf -Name 'AzureSubscriptions' -ScriptBlock { Get-O365OrgBackup -Headers $Headers -Name AzureSubscriptions }
                    Invoke-HealthLeaf -Name 'EnhancedRestoreStatus' -ScriptBlock { Get-O365OrgBackup -Headers $Headers -Name EnhancedRestoreStatus }
                )
            }
        }
        ContentUnderstanding = {
            if ($Mode -eq 'Deep') {
                Get-O365ContentUnderstanding -Headers $Headers -Name All
            } else {
                New-HealthLeafBundle -Leaves @(
                    Invoke-HealthLeaf -Name 'Setting' -ScriptBlock { Get-O365ContentUnderstanding -Headers $Headers -Name Setting }
                    Invoke-HealthLeaf -Name 'Licensing' -ScriptBlock { Get-O365ContentUnderstanding -Headers $Headers -Name Licensing }
                    Invoke-HealthLeaf -Name 'BillingSettings' -ScriptBlock { Get-O365ContentUnderstanding -Headers $Headers -Name BillingSettings }
                )
            }
        }
        PayAsYouGo = {
            if ($Mode -eq 'Deep') {
                Get-O365PayAsYouGoService -Headers $Headers -Name All
            } else {
                New-HealthLeafBundle -Leaves @(
                    Invoke-HealthLeaf -Name 'DataLocationAndCommitments' -ScriptBlock { Get-O365PayAsYouGoService -Headers $Headers -Name DataLocationAndCommitments }
                    Invoke-HealthLeaf -Name 'Telemetry' -ScriptBlock { Get-O365PayAsYouGoService -Headers $Headers -Name Telemetry }
                )
            }
        }
    }

    foreach ($CurrentArea in $SelectedAreas) {
        $StartedAt = Get-Date
        $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $Result = Get-ValidationResult -AreaName $CurrentArea -ScriptBlock $AreaDefinitions[$CurrentArea]
        $Stopwatch.Stop()
        $CompletedAt = Get-Date
        $AreaSummary = Get-O365UnavailableSummary -InputObject $Result
        $Components = @(Get-HealthComponents -Result $Result)
        $ComponentDetails = @(
            foreach ($Component in $Components) {
                $ComponentSummary = Get-O365UnavailableSummary -InputObject $Component.Value
                $UnavailableItems = @($ComponentSummary.Items)
                [PSCustomObject] @{
                    Name                = $Component.Name
                    Status              = if (-not $ComponentSummary.HasUnavailableItems) { 'Healthy' } elseif (Test-O365UnavailableResult -InputObject $Component.Value) { 'Unavailable' } else { 'Partial' }
                    SuggestedCommand    = Get-SuggestedCommand -AreaName $CurrentArea -ComponentName $Component.Name
                    StartedAt           = $Component.StartedAt
                    CompletedAt         = $Component.CompletedAt
                    ElapsedMilliseconds = $Component.ElapsedMilliseconds
                    UnavailableCount    = $ComponentSummary.UnavailableCount
                    UnavailableNames    = @($ComponentSummary.Names)
                    UnavailablePaths    = @($ComponentSummary.Paths)
                    UnavailableReasons  = @($ComponentSummary.Reasons)
                    UnavailableItems    = $UnavailableItems
                }
            }
        )

        $HealthyComponents = @($ComponentDetails | Where-Object Status -eq 'Healthy').Count
        $PartialComponents = @($ComponentDetails | Where-Object Status -eq 'Partial').Count
        $UnavailableComponents = @($ComponentDetails | Where-Object Status -eq 'Unavailable').Count

        $Status = if (-not $AreaSummary.HasUnavailableItems) {
            'Healthy'
        } elseif ($UnavailableComponents -eq $ComponentDetails.Count) {
            'Unavailable'
        } else {
            'Partial'
        }

        $Output = [ordered] @{
            Area                  = $CurrentArea
            Mode                  = $Mode
            CheckedAt             = $CompletedAt
            StartedAt             = $StartedAt
            CompletedAt           = $CompletedAt
            ElapsedMilliseconds   = [int] [Math]::Round($Stopwatch.Elapsed.TotalMilliseconds, 0)
            Status                = $Status
            ComponentCount        = $ComponentDetails.Count
            HealthyComponents     = $HealthyComponents
            PartialComponents     = $PartialComponents
            UnavailableComponents = $UnavailableComponents
            UnavailableCount      = $AreaSummary.UnavailableCount
            UnavailableNames      = @($AreaSummary.Names)
            UnavailablePaths      = @($AreaSummary.Paths)
            Components            = $ComponentDetails
        }

        if ($IncludeResult) {
            $Output['Result'] = $Result
        }

        [PSCustomObject] $Output
    }
}
