function Get-O365OrgDynamics365CustomerVoice {
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