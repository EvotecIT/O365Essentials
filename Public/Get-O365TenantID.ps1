function Get-O365TenantID {
    <#
    .SYNOPSIS
    Quick way to find Office 365 Tenant ID by using domain name

    .DESCRIPTION
    Quick way to find Office 365 Tenant ID by using domain name

    .PARAMETER Domain
    Domain name to check

    .EXAMPLE
    Get-O365TenantID -Domain 'evotec.pl'

    .NOTES
    General notes
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory)][alias('DomainName')][string] $Domain
    )
    $Invoke = Invoke-RestMethod "https://login.windows.net/$Domain/.well-known/openid-configuration" -Method GET -Verbose:$false
    if ($Invoke) {
        $Invoke.userinfo_endpoint.Split("/")[3]
    }
}