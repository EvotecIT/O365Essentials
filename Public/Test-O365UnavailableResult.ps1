function Test-O365UnavailableResult {
    <#
    .SYNOPSIS
    Tests whether an object is an O365Essentials unavailable placeholder result.

    .DESCRIPTION
    Returns True when the provided object is a structured unavailable result created by
    O365Essentials for tenant-specific or otherwise unavailable internal admin payloads.

    .PARAMETER InputObject
    Object to inspect.

    .EXAMPLE
    Get-O365CopilotOverview -Name Security | ForEach-Object {
        $_.PSObject.Properties.Value | Where-Object { Test-O365UnavailableResult $_ }
    }
    #>
    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipeline)] $InputObject
    )

    process {
        if ($null -eq $InputObject) {
            return $false
        }

        if ($InputObject.PSObject -and $InputObject.PSObject.TypeNames -contains 'O365Essentials.UnavailableResult') {
            return $true
        }

        if ($InputObject.PSObject -and $InputObject.PSObject.Properties.Match('IsUnavailable').Count -gt 0) {
            return [bool] $InputObject.IsUnavailable
        }

        return $false
    }
}
