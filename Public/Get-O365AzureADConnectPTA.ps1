function Get-O365AzureADConnectPTA {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

    .EXAMPLE
    Get-O365ModernAuthentication -Verbose

    .NOTES
    https://portal.azure.com/#blade/Microsoft_AAD_IAM/PassThroughAuthenticationConnectorsBlade
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/Directories/PassThroughAuthConnectorGroups"
    $Output1 = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output1
}