function Get-O365AzureExternalCollaborationRestrictions {
    <#
    .SYNOPSIS
    Retrieves Azure external collaboration restrictions based on the provided headers.

    .DESCRIPTION
    This function retrieves Azure external collaboration restrictions from the specified API endpoint using the provided headers. It can also translate the output into a more readable format if the -NoTranslation switch is not used.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER NoTranslation
    A switch parameter to indicate whether to skip translation of the output. If used, the raw output will be returned without any additional processing.

    .EXAMPLE
    Get-O365AzureExternalCollaborationRestrictions -Headers $headers -NoTranslation

    .NOTES
    This function is designed to work in conjunction with Connect-O365Admin to fetch the necessary headers for authentication. It retrieves the Azure external collaboration restrictions, which include settings and configurations related to external collaboration.
    #>
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