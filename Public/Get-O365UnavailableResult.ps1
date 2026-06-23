function Get-O365UnavailableResult {
    <#
    .SYNOPSIS
    Finds structured unavailable placeholder results in an object graph.

    .DESCRIPTION
    Walks nested O365Essentials result objects and returns each unavailable placeholder
    together with the path where it was found.

    .PARAMETER InputObject
    Object to inspect.

    .EXAMPLE
    $result = Get-O365CopilotOverview -Name Security
    Get-O365UnavailableResult -InputObject $result
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)] $InputObject
    )

    begin {
    }

    process {
        Visit-O365UnavailableNode -Node $InputObject -Path '$'
    }
}
