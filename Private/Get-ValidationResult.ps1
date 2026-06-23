function Get-ValidationResult {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $AreaName,
        [Parameter(Mandatory)][scriptblock] $ScriptBlock
    )

    try {
        & $ScriptBlock
    }
    catch {
        New-O365UnavailableResult -Name $AreaName -Area 'Internal API health check' -Description 'The internal API health check could not complete this area.' -Reason 'ValidationError' -SuggestedAction 'Run the area cmdlet directly with -Verbose for route-level details.' -ErrorMessage $_.Exception.Message
    }
}
