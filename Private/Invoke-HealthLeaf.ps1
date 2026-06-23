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
    }
    catch {
        $Value = New-O365UnavailableResult -Name $Name -Area 'Internal API health check component' -Description 'The internal API health check component did not return a usable payload.' -Reason 'ValidationError' -SuggestedAction 'Run the component cmdlet directly with -Verbose for route-level details.' -ErrorMessage $_.Exception.Message
    }
    finally {
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
