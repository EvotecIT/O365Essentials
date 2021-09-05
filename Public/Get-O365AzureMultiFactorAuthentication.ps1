function Get-O365AzureMultiFactorAuthentication {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Headers
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    Based on: https://portal.azure.com/#blade/Microsoft_AAD_IAM/MultifactorAuthenticationMenuBlade/GettingStarted/fromProviders/

    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    #$Uri = "https://main.iam.ad.ext.azure.com/api/MultiFactorAuthentication/GetOrCreateExpandedTenantModel?tenantName=Evotec"
    $Uri = "https://main.iam.ad.ext.azure.com/api/MultiFactorAuthentication/GetOrCreateExpandedTenantModel"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}