function Set-O365AzureExternalCollaborationRestrictions {
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