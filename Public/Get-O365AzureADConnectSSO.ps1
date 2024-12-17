function Get-O365AzureADConnectSSO {
    <#
    .SYNOPSIS
    Retrieves information about Azure AD Connect with Pass-Through Authentication (PTA).

    .DESCRIPTION
    This function retrieves detailed information about Azure AD Connect with Pass-Through Authentication (PTA) connectors.

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

    .EXAMPLE
    Get-O365AzureADConnect -Verbose

    .NOTES
    For more information, visit: https://portal.azure.com/#blade/Microsoft_AAD_IAM/PassThroughAuthenticationConnectorsBlade
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/Directories/GetSeamlessSingleSignOnDomains"
    $Output2 = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output2
}
