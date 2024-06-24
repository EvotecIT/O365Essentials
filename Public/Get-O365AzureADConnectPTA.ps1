function Get-O365AzureADConnectPTA {
    <#
        .SYNOPSIS
        Retrieves the status of Pass-Through Authentication (PTA) connectors for Office 365.
        .DESCRIPTION
        This function calls the Azure AD API to get the status of Pass-Through Authentication (PTA) connectors.
        It returns the details of the PTA connector groups.
        .PARAMETER Headers
        Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.
        .EXAMPLE
        Get-O365AzureADConnectPTA -Headers $headers
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
