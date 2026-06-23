function Get-ProcessEnvironmentValue {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $Name
    )

    [Environment]::GetEnvironmentVariable($Name, 'Process')
}
