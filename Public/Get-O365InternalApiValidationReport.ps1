function Get-O365InternalApiValidationReport {
    <#
    .SYNOPSIS
    Builds a consolidated validation report for O365Essentials internal API coverage.

    .DESCRIPTION
    Runs Get-O365InternalApiHealth and Get-O365InternalApiFinding, then assembles a single
    report object with area summaries, flattened findings, prioritized findings, and
    suggested rerun commands. This is intended for pre-live-validation review and later
    tenant validation runs.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Area
    Limits validation to one or more areas. Use All to validate the full set.

    .PARAMETER Mode
    Standard keeps the validation lighter and faster. Deep runs the broader grouped bundles.

    .PARAMETER IncludeHealthyFindings
    Includes healthy components in the flattened findings list.

    .PARAMETER IncludeResult
    Includes the raw area results inside the underlying health objects.

    .EXAMPLE
    Get-O365InternalApiValidationReport

    .EXAMPLE
    Get-O365InternalApiValidationReport -Area Copilot, MicrosoftEdge -Mode Deep
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('Agents', 'All', 'Backup', 'BrandCenter', 'ContentUnderstanding', 'Copilot', 'IntegratedApps', 'MicrosoftEdge', 'PayAsYouGo', 'People', 'Search', 'TenantRelationship', 'Viva')][string[]] $Area = @('TenantRelationship', 'People', 'IntegratedApps', 'BrandCenter', 'MicrosoftEdge', 'Viva', 'Agents', 'Copilot', 'Search', 'Backup'),
        [ValidateSet('Standard', 'Deep')][string] $Mode = 'Standard',
        [switch] $IncludeHealthyFindings,
        [switch] $IncludeResult
    )

    function Get-FindingPriority {
        [cmdletbinding()]
        param(
            [string] $Reason,
            [bool] $IsOptional
        )

        if ($IsOptional) {
            return 'Low'
        }

        switch ($Reason) {
            'AuthorizationError' { 'High' }
            'MissingTenantId' { 'High' }
            'PortalSessionRequired' { 'High' }
            'ValidationError' { 'High' }
            'UndiscoveredEndpoint' { 'High' }
            'TenantSpecific' { 'Medium' }
            default {
                if ([string]::IsNullOrWhiteSpace($Reason)) { 'Info' } else { 'Medium' }
            }
        }
    }

    function Get-PriorityRank {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $Priority
        )

        switch ($Priority) {
            'High' { 0 }
            'Medium' { 1 }
            'Low' { 2 }
            default { 3 }
        }
    }

    $Health = @(Get-O365InternalApiHealth -Headers $Headers -Area $Area -Mode $Mode -IncludeResult:$IncludeResult)
    $Findings = @(
        if ($IncludeHealthyFindings) {
            $Health | Get-O365InternalApiFinding -IncludeHealthy
        } else {
            $Health | Get-O365InternalApiFinding
        }
    )

    $PrioritizedFindings = @(
        foreach ($Finding in $Findings) {
            $Priority = Get-FindingPriority -Reason $Finding.Reason -IsOptional $Finding.IsOptional
            [PSCustomObject] @{
                Area                       = $Finding.Area
                Mode                       = $Finding.Mode
                AreaStatus                 = $Finding.AreaStatus
                Component                  = $Finding.Component
                ComponentStatus            = $Finding.ComponentStatus
                ComponentElapsedMilliseconds = $Finding.ComponentElapsedMilliseconds
                Name                       = $Finding.Name
                Reason                     = $Finding.Reason
                IsOptional                 = [bool] $Finding.IsOptional
                Priority                   = $Priority
                PriorityRank               = Get-PriorityRank -Priority $Priority
                Path                       = $Finding.Path
                Description                = $Finding.Description
                SuggestedAction            = $Finding.SuggestedAction
                SuggestedCommand           = $Finding.SuggestedCommand
            }
        }
    ) | Sort-Object PriorityRank, Area, Component, Name

    $RecommendedCommands = @(
        $PrioritizedFindings |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_.SuggestedCommand) } |
            Select-Object -ExpandProperty SuggestedCommand -Unique
    )

    $TotalElapsedMilliseconds = @(
        $Health |
            Where-Object { $_.PSObject.Properties.Name -contains 'ElapsedMilliseconds' } |
            Measure-Object -Property ElapsedMilliseconds -Sum
    )[0].Sum

    $SlowestAreas = @(
        $Health |
            Where-Object { $_.PSObject.Properties.Name -contains 'ElapsedMilliseconds' } |
            Sort-Object ElapsedMilliseconds -Descending |
            Select-Object -First 5 Area, Status, ElapsedMilliseconds, UnavailableCount
    )

    $SlowestComponents = @(
        foreach ($AreaResult in $Health) {
            foreach ($Component in @($AreaResult.Components)) {
                if ($null -eq $Component.ElapsedMilliseconds) {
                    continue
                }

                [PSCustomObject] @{
                    Area                = $AreaResult.Area
                    AreaStatus          = $AreaResult.Status
                    Component           = $Component.Name
                    ComponentStatus     = $Component.Status
                    ElapsedMilliseconds = $Component.ElapsedMilliseconds
                    SuggestedCommand    = $Component.SuggestedCommand
                    UnavailableCount    = $Component.UnavailableCount
                }
            }
        }
    ) | Sort-Object ElapsedMilliseconds -Descending | Select-Object -First 10

    $Summary = [PSCustomObject] @{
        CheckedAt           = Get-Date
        Mode                = $Mode
        AreaCount           = $Health.Count
        TotalElapsedMilliseconds = if ($null -ne $TotalElapsedMilliseconds) { [int] [Math]::Round($TotalElapsedMilliseconds, 0) } else { 0 }
        HealthyAreas        = @($Health | Where-Object Status -eq 'Healthy').Count
        PartialAreas        = @($Health | Where-Object Status -eq 'Partial').Count
        UnavailableAreas    = @($Health | Where-Object Status -eq 'Unavailable').Count
        FindingCount        = $PrioritizedFindings.Count
        HighPriorityCount   = @($PrioritizedFindings | Where-Object Priority -eq 'High').Count
        MediumPriorityCount = @($PrioritizedFindings | Where-Object Priority -eq 'Medium').Count
        LowPriorityCount    = @($PrioritizedFindings | Where-Object Priority -eq 'Low').Count
        InfoCount           = @($PrioritizedFindings | Where-Object Priority -eq 'Info').Count
    }

    [PSCustomObject] @{
        Summary             = $Summary
        AreaResults         = $Health
        SlowestAreas        = $SlowestAreas
        SlowestComponents   = $SlowestComponents
        Findings            = $Findings
        PrioritizedFindings = $PrioritizedFindings
        RecommendedCommands = $RecommendedCommands
    }
}
