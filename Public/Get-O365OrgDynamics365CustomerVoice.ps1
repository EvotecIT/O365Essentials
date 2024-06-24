function Get-O365OrgDynamics365CustomerVoice {
    <#
        .SYNOPSIS
        Retrieves Dynamics 365 Customer Voice information for the organization.
        .DESCRIPTION
        This function retrieves Dynamics 365 Customer Voice information for the organization from the specified API endpoint using the provided headers.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .EXAMPLE
        Get-O365OrgDynamics365CustomerVoice -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
    $Uri = 'https://admin.microsoft.com/admin/api/settings/apps/officeformspro'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        if ($NoTranslation) {
            $Output
        } else {
            [PSCustomObject] @{
                # Distribution section
                ReduceSurveyFatigueEnabled     = $Output.OverSurveyManagementEnabled    # : False
                ReduceSurveyFatigueDays        = $Output.OverSurveyManagementDays       # : 0
                CustomDomainEmails             = $Output.CustomDomainEmails             # : {}
                # Security section
                PreventPhishingAttemptsEnabled = $Output.InOrgFormsPhishingScanEnabled  # : True
                CollectNamesEnabled            = $Output.RecordIdentityByDefaultEnabled # : True
                RestrictSurveyAccessEnabled    = $Output.RestrictSurveyAccessEnabled    # : False

#               # not sure
                InOrgSurveyIncentiveEnabled    = $Output.InOrgSurveyIncentiveEnabled    # : False
                RequestType                    = $Output.RequestType                    # : 0
                ValidateDomain                 = $Output.ValidateDomain                 # :
            }
        }
    }
}
