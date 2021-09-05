function Get-O365AzureEnterpriseAppsUserSettings {
    # https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/configure-user-consent?tabs=azure-portal
    # https://portal.azure.com/#blade/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/UserSettings
    # https://portal.azure.com/#blade/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/UserSettings/menuId/
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
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