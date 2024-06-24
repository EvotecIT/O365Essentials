function Get-O365AzureEnterpriseAppsUserSettingsPromoted {
    <#
        .SYNOPSIS
        Retrieves user settings for promoted Azure Enterprise Apps.
        .DESCRIPTION
        This function retrieves user settings for promoted Azure Enterprise Apps based on the provided headers.
        .PARAMETER Headers
        A dictionary containing the headers for the API request, typically including authorization information.
        .EXAMPLE
        Get-O365AzureEnterpriseAppsUserSettingsPromoted -Headers $headers
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
    # https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/configure-user-consent?tabs=azure-portal
    # https://portal.azure.com/#blade/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/UserSettings
    # https://portal.azure.com/#blade/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/UserSettings/menuId/
    $Uri = 'https://main.iam.ad.ext.azure.com/api/workspaces/promotedapps'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
