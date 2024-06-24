function Get-O365AzureMultiFactorAuthentication {
    <#
    .SYNOPSIS
    Retrieves the Multi-Factor Authentication settings for the specified tenant.

    .DESCRIPTION
    This function retrieves the Multi-Factor Authentication settings for the specified tenant using the provided headers.

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

    .EXAMPLE
    Get-O365AzureMultiFactorAuthentication -Verbose
    An example of how to retrieve Multi-Factor Authentication settings for a tenant.

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
