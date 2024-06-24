function Get-O365AzureEnterpriseAppsUserSettingsAdmin {
    <#
        .SYNOPSIS
        Retrieves user settings for Azure Enterprise Apps with admin consent flow.
        .DESCRIPTION
        This function retrieves user settings for Azure Enterprise Apps with admin consent flow based on the provided headers.
        It returns information about request expiration days, notifications, reminders, approvers, and approversV2.
        .PARAMETER Headers
        A dictionary containing the headers for the API request, typically including authorization information.
        .PARAMETER NoTranslation
        Specifies whether to return the user settings without translation.
        .EXAMPLE
        Get-O365AzureEnterpriseAppsUserSettingsAdmin -Headers $headers
        .NOTES
        For more information, visit: https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/configure-user-consent?tabs=azure-portal
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
    # https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/configure-user-consent?tabs=azure-portal
    # https://portal.azure.com/#blade/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/UserSettings
    # https://portal.azure.com/#blade/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/UserSettings/menuId/
    $Uri = 'https://main.iam.ad.ext.azure.com/api/RequestApprovals/V2/PolicyTemplates?type=AdminConsentFlow'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        if ($NoTranslation) {
            $Output
        } else {
            [PSCustomObject] @{
                requestExpiresInDays = $Output.requestExpiresInDays
                notificationsEnabled = $Output.notificationsEnabled
                remindersEnabled     = $Output.remindersEnabled
                approvers            = $Output.approvers
                approversV2          = $Output.approversV2
            }
        }
    }
}
