function Set-O365AzureEnterpriseAppsUserSettings {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Headers
    Parameter description

    .PARAMETER UsersCanConsentAppsAccessingData
    Parameter description

    .PARAMETER UsersCanAddGalleryAppsToMyApp
    Parameter description

    .PARAMETER UsersCanOnlySeeO365AppsInPortal
    Parameter description

    .EXAMPLE
    An example

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