function Get-O365AzureExternalCollaborationRestrictions {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
    $Uri = 'https://main.iam.ad.ext.azure.com/api/B2B/b2bPolicy'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        if ($NoTranslation) {
            $Output

            <#
            targetedDomains                     : {}
            hasListEntries                      : True
            isAllowlist                         : False
            otpEnabled                          : False
            adminConsentedForUsersIntoTenantIds : {}
            noAADConsentForUsersFromTenantsIds  : {}
            #>
        } else {

            if ($Output.isAllowlist -eq $true -and $Output.targetedDomains.count -eq 0) {
                $CollaborationRestrictions = 'AllowAnyDomain'
            } elseif ($Output.isAllowlist -eq $true -and $Output.targetedDomains.count -gt 0) {
                $CollaborationRestrictions = 'AllowSpecifiedDomains'
            } elseif ($Output.isAllowlist -eq $false -and $Output.targetedDomains.count -eq 0) {
                # Won't really happen as microsoft doesn't allow to to have 0 domains for allowed domains
                $CollaborationRestrictions = 'DisallowAnyDomain'
            } elseif ($Output.isAllowlist -eq $false -and $Output.targetedDomains.count -gt 0) {
                $CollaborationRestrictions = 'DisallowSpecifiedDomains'
            } else {
                # Won't really happen
                $CollaborationRestrictions = 'Unknown'
            }

            [PSCustomObject] @{
                CollaborationRestrictions = $CollaborationRestrictions
                TargetedDomains           = $Output.targetedDomains                     #
                #hasListEntries            = $Output.hasListEntries                      # : True
                #isAllowlist               = $Output.isAllowlist                         # : False
                #otpEnabled                          = $Output.otpEnabled                          # : False
                #adminConsentedForUsersIntoTenantIds = $Output.adminConsentedForUsersIntoTenantIds # : {}
                #noAADConsentForUsersFromTenantsIds  = $Output.noAADConsentForUsersFromTenantsIds  # : {}          # :
            }
        }
    }
}