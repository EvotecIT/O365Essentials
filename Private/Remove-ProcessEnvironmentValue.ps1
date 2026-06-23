function Remove-ProcessEnvironmentValue {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $Name
    )

    [Environment]::SetEnvironmentVariable($Name, $null, 'Process')
}
