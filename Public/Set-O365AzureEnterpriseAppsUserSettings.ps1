function Set-O365AzureEnterpriseAppsUserSettings {
    <#
    .SYNOPSIS
    Configures user settings for Azure enterprise applications.

    .DESCRIPTION
    This function allows administrators to configure user settings for Azure enterprise applications.

    .PARAMETER Headers
    Specifies the headers for the API request, typically including authorization tokens.

    .PARAMETER UsersCanConsentAppsAccessingData
    Specifies whether users can consent to apps accessing company data.

    .PARAMETER UsersCanAddGalleryAppsToMyApp
    Specifies whether users can add gallery apps to their applications.

    .PARAMETER UsersCanOnlySeeO365AppsInPortal
    Specifies whether users can only see Office 365 apps in the portal.

    .EXAMPLE
    An example of how to use this function:
    Set-O365AzureEnterpriseAppsUserSettings -Headers $headers -UsersCanConsentAppsAccessingData $true -UsersCanAddGalleryAppsToMyApp $false -UsersCanOnlySeeO365AppsInPortal $true

    .NOTES
    Please keep in mind that:
    - Users can consent to apps accessing company data for the groups they own -> can be set using Set-O3465AzureEnterpriseAppsGroupConsent
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $UsersCanConsentAppsAccessingData,
        [nullable[bool]] $UsersCanAddGalleryAppsToMyApp,
        [nullable[bool]] $UsersCanOnlySeeO365AppsInPortal
    )

    $Uri = 'https://main.iam.ad.ext.azure.com/api/EnterpriseApplications/UserSettings'

    # contrary to most of the cmdlets it seem if you provide null as values not filled in, nothing is changed
    # Body "{`"usersCanAllowAppsToAccessData`":false,`"usersCanAddGalleryApps`":null,`"hideOffice365Apps`":null}"
    $Body = @{
        usersCanAllowAppsToAccessData = $UsersCanConsentAppsAccessingData
        usersCanAddGalleryApps        = $UsersCanAddGalleryAppsToMyApp
        hideOffice365Apps             = $UsersCanOnlySeeO365AppsInPortal
    }
    # But we're going to remove those empty entries anyways
    Remove-EmptyValue -Hashtable $Body
    if ($Body.Keys.Count -gt 0) {
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PATCH -Body $Body
    }
}
