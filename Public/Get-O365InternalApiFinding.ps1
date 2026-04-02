function Get-O365InternalApiFinding {
    <#
    .SYNOPSIS
    Flattens internal API health results into actionable findings.

    .DESCRIPTION
    Converts Get-O365InternalApiHealth output into a simple list of findings that can be
    filtered, exported, or used during live tenant validation. Each finding includes the
    affected area, component, unavailable placeholder details, and the suggested command
    to rerun directly.

    .PARAMETER InputObject
    Health result object returned by Get-O365InternalApiHealth.

    .PARAMETER IncludeHealthy
    Includes healthy components in the flattened output.

    .EXAMPLE
    Get-O365InternalApiHealth | Get-O365InternalApiFinding

    .EXAMPLE
    Get-O365InternalApiHealth -Area Copilot, Viva | Get-O365InternalApiFinding |
        Select-Object Area, Component, Name, Reason, SuggestedCommand
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)] $InputObject,
        [switch] $IncludeHealthy
    )

    process {
        if ($null -eq $InputObject -or -not $InputObject.PSObject.Properties.Match('Components')) {
            return
        }

        foreach ($Component in @($InputObject.Components)) {
            if (-not $IncludeHealthy -and $Component.Status -eq 'Healthy') {
                continue
            }

            if (@($Component.UnavailableItems).Count -eq 0) {
                [PSCustomObject] @{
                    Area                      = $InputObject.Area
                    Mode                      = $InputObject.Mode
                    AreaStatus                = $InputObject.Status
                    Component                 = $Component.Name
                    ComponentStatus           = $Component.Status
                    ComponentElapsedMilliseconds = $Component.ElapsedMilliseconds
                    Name                      = $null
                    Reason                    = $null
                    IsOptional                = $false
                    Path                      = $null
                    Description               = $null
                    SuggestedAction           = $null
                    SuggestedCommand          = $Component.SuggestedCommand
                }
                continue
            }

            foreach ($Item in @($Component.UnavailableItems)) {
                [PSCustomObject] @{
                    Area                      = $InputObject.Area
                    Mode                      = $InputObject.Mode
                    AreaStatus                = $InputObject.Status
                    Component                 = $Component.Name
                    ComponentStatus           = $Component.Status
                    ComponentElapsedMilliseconds = $Component.ElapsedMilliseconds
                    Name                      = $Item.Name
                    Reason                    = $Item.Reason
                    IsOptional                = if ($Item.Result) { [bool] $Item.Result.IsOptional } else { $false }
                    Path                      = $Item.Path
                    Description               = $Item.Description
                    SuggestedAction           = if ($Item.Result) { $Item.Result.SuggestedAction } else { $null }
                    SuggestedCommand          = $Component.SuggestedCommand
                }
            }
        }
    }
}
