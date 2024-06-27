function Set-O365AzureExternalCollaborationRestrictions {
    <#
    .SYNOPSIS
    Configures external collaboration restrictions for Office 365 Azure.

    .DESCRIPTION
    This function allows administrators to configure various restrictions related to external collaboration in Office 365 Azure. It includes options for managing collaboration domains and settings.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER CollaborationRestrictions
    Specifies the type of collaboration restrictions to be applied. Valid values are 'AllowAnyDomains', 'AllowSpecifiedDomains', 'DisallowSpecifiedDomains'.

    .PARAMETER TargetedDomains
    Specifies the domains to be targeted. This parameter is used when CollaborationRestrictions is set to 'AllowSpecifiedDomains' or 'DisallowSpecifiedDomains'.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365AzureExternalCollaborationRestrictions -Headers $headers -CollaborationRestrictions "AllowAnyDomains"

    This example allows any domains for external collaboration.

    .LINK
    https://main.iam.ad.ext.azure.com/api/B2B/b2bPolicy
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('AllowAnyDomains', 'AllowSpecifiedDomains', 'DisallowSpecifiedDomains')][string] $CollaborationRestrictions,
        [string[]] $TargetedDomains
    )

    $Uri = 'https://main.iam.ad.ext.azure.com/api/B2B/b2bPolicy'

    # $Body = @{
    #     targetedDomains                     = $UsersCanConsentAppsAccessingData
    #     isAllowlist                         = $UsersCanAddGalleryAppsToMyApp
    #     hasListEntries                      = $UsersCanOnlySeeO365AppsInPortal
    #     otpEnabled                          = $otpEnabled
    #     adminConsentedForUsersIntoTenantIds = @()
    #     noAADConsentForUsersFromTenantsIds  = @()
    # }

    if ($CollaborationRestrictions -eq 'AllowAnyDomains') {
        $Body = @{
            targetedDomains = @()
            isAllowlist     = $true
            #hasListEntries                      = $true
            #otpEnabled                          = $false
            #adminConsentedForUsersIntoTenantIds = @()
            #noAADConsentForUsersFromTenantsIds  = @()
        }
    } elseif ($CollaborationRestrictions -eq 'AllowSpecifiedDomains') {
        $Body = @{
            targetedDomains = @($TargetedDomains)
            isAllowlist     = $true
            #hasListEntries                      = $true
            #otpEnabled                          = $false
            #adminConsentedForUsersIntoTenantIds = @()
            #noAADConsentForUsersFromTenantsIds  = @()
        }
    } elseif ($CollaborationRestrictions -eq 'DisallowSpecifiedDomains') {
        $Body = @{
            targetedDomains = @($TargetedDomains)
            isAllowlist     = $false
            #hasListEntries                      = $true
            #otpEnabled                          = $false
            #adminConsentedForUsersIntoTenantIds = @()
            #noAADConsentForUsersFromTenantsIds  = @()
        }
    }

    #Remove-EmptyValue -Hashtable $Body
    if ($Body.Keys.Count -gt 0) {
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    }
}