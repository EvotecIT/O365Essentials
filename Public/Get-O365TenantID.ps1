function Get-O365TenantID {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Domain
    Parameter description

    .EXAMPLE
    Get-O365TenantID -Domain 'evotec.pl'

    .NOTES
    General notes
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory)][string] $Domain
    )
    (Invoke-RestMethod "https://login.windows.net/$Domain/.well-known/openid-configuration" -Method GET).userinfo_endpoint.Split("/")[3]
}

