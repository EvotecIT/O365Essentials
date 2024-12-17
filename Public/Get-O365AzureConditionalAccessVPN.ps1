function Get-O365AzureConditionalAccessVPN {
    <#
    .SYNOPSIS
    Retrieves VPN certificates for Azure Conditional Access.

    .DESCRIPTION
    This function retrieves VPN certificates for Azure Conditional Access based on the provided headers.

    .PARAMETER Headers
    A dictionary containing the headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365AzureConditionalAccessVPN -Headers $headers

    .NOTES
    For more information, visit: 
    - https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/configure-user-consent?tabs=azure-portal
    - https://portal.azure.com/#blade/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/UserSettings
    - https://portal.azure.com/#blade/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/UserSettings/menuId/
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://main.iam.ad.ext.azure.com/api/Vpn/Certificates'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        $Output
    }
}