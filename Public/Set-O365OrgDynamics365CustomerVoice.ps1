function Set-O365OrgDynamics365CustomerVoice {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter()][bool] $ReduceSurveyFatigueEnabled,
        [Parameter()][int] $ReduceSurveyFatigueDays,
        [Parameter()][Array] $CustomDomainEmails,
        [Parameter()][bool] $PreventPhishingAttemptsEnabled,
        [Parameter()][bool] $CollectNamesEnabled,
        [Parameter()][bool] $RestrictSurveyAccessEnabled
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/officeformspro"

    $CurrentSettings = Get-O365OrgDynamics365CustomerVoice -Headers $Headers -NoTranslation

    $Body = [ordered] @{
        "RecordIdentityByDefaultEnabled" = $CurrentSettings.RecordIdentityByDefaultEnabled
        "InOrgFormsPhishingScanEnabled"  = $CurrentSettings.InOrgFormsPhishingScanEnabled
        "OverSurveyManagementEnabled"    = $CurrentSettings.OverSurveyManagementEnabled
        "OverSurveyManagementDays"       = $CurrentSettings.OverSurveyManagementDays
        "CustomDomainEmails"             = $CurrentSettings.CustomDomainEmails
        "RestrictSurveyAccessEnabled"    = $CurrentSettings.RestrictSurveyAccessEnabled
    }

    if ($PSBoundParameters.ContainsKey("ReduceSurveyFatigueEnabled")) {
        $Body["OverSurveyManagementEnabled"] = $ReduceSurveyFatigueEnabled
    }
    if ($PSBoundParameters.ContainsKey("ReduceSurveyFatigueDays")) {
        $Body["OverSurveyManagementDays"] = $ReduceSurveyFatigueDays
    }
    if ($PSBoundParameters.ContainsKey("CustomDomainEmails")) {
        $Body["CustomDomainEmails"] = $CustomDomainEmails
    }
    if ($PSBoundParameters.ContainsKey("PreventPhishingAttemptsEnabled")) {
        $Body["InOrgFormsPhishingScanEnabled"] = $PreventPhishingAttemptsEnabled
    }
    if ($PSBoundParameters.ContainsKey("CollectNamesEnabled")) {
        $Body["RecordIdentityByDefaultEnabled"] = $CollectNamesEnabled
    }
    if ($PSBoundParameters.ContainsKey("RestrictSurveyAccessEnabled")) {
        $Body["RestrictSurveyAccessEnabled"] = $RestrictSurveyAccessEnabled
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}