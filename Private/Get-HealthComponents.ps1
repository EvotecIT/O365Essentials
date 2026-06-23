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
                Name                = 'Result'
                Value               = $Result
                StartedAt           = $null
                CompletedAt         = $null
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
