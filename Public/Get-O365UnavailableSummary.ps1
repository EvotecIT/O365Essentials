function Get-O365UnavailableSummary {
    <#
    .SYNOPSIS
    Summarizes unavailable placeholder results found in an object graph.

    .DESCRIPTION
    Inspects nested O365Essentials results and returns a compact summary of any
    structured unavailable placeholders that were found.

    .PARAMETER InputObject
    Object to inspect.

    .EXAMPLE
    $result = Get-O365CopilotOverview -Name Security
    Get-O365UnavailableSummary -InputObject $result
    #>
    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipeline)] $InputObject
    )

    process {
        if ($null -eq $InputObject) {
            [PSCustomObject] @{
                HasUnavailableItems = $false
                UnavailableCount    = 0
                Names               = @()
                Reasons             = @()
                Paths               = @()
                Items               = @()
            }
            return
        }

        $Items = @(Get-O365UnavailableResult -InputObject $InputObject)

        [PSCustomObject] @{
            HasUnavailableItems = $Items.Count -gt 0
            UnavailableCount    = $Items.Count
            Names               = @($Items.Name | Sort-Object -Unique)
            Reasons             = @($Items.Reason | Sort-Object -Unique)
            Paths               = @($Items.Path)
            Items               = $Items
        }
    }
}
