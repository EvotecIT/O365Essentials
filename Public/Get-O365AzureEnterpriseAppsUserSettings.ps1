function Get-O365AzureEnterpriseAppsUserSettings {
    <#
        .SYNOPSIS
        Retrieves user settings for Azure Enterprise Apps.
        .DESCRIPTION
        This function retrieves user settings for Azure Enterprise Apps based on the provided headers.
        It returns information about user consent settings for accessing data, adding gallery apps, and visibility of Office 365 apps in the portal.
        .PARAMETER Headers
        A dictionary containing the headers for the API request, typically including authorization information.
        .PARAMETER NoTranslation
        Specifies whether to return the user settings without translation.
        .EXAMPLE
        Get-O365AzureEnterpriseAppsUserSettings -Headers $headers
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
    $Uri = 'https://main.iam.ad.ext.azure.com/api/EnterpriseApplications/UserSettings'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        if ($NoTranslation) {
            $Output
        } else {
            [PSCustomObject] @{
                UsersCanConsentAppsAccessingData = $Output.usersCanAllowAppsToAccessData
                UsersCanAddGalleryAppsToMyApp    = $Output.usersCanAddGalleryApps
                UsersCanOnlySeeO365AppsInPortal  = $Output.hideOffice365Apps
            }
        }
    }
}
