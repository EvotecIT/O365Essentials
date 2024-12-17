function Get-O365TenantID {
    <#
    .SYNOPSIS
    Provides the tenant ID for a given domain.

    .DESCRIPTION
    This function retrieves the tenant ID associated with a specific domain by querying the OpenID configuration endpoint.

    .PARAMETER Domain
    Specifies the domain for which to retrieve the tenant ID.

    .EXAMPLE
    Get-O365TenantID -Domain 'evotec.pl'

    .NOTES
    For more information, refer to the OpenID Connect Discovery documentation.
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
