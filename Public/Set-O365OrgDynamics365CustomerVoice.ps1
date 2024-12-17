function Set-O365OrgDynamics365CustomerVoice {
    <#
    .SYNOPSIS
    Configures the Dynamics 365 Customer Voice settings for an Office 365 organization.

    .DESCRIPTION
    This function allows you to enable or disable the Dynamics 365 Customer Voice service for your Office 365 organization. 
    It sends a POST request to the Office 365 admin API with the specified settings.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER ReduceSurveyFatigueEnabled
    Specifies whether the Reduce Survey Fatigue feature should be enabled.

    .PARAMETER ReduceSurveyFatigueDays
    Specifies the number of days to reduce survey fatigue.

    .PARAMETER CustomDomainEmails
    Specifies the custom domain emails for the organization.

    .PARAMETER PreventPhishingAttemptsEnabled
    Specifies whether the Prevent Phishing Attempts feature should be enabled.

    .PARAMETER CollectNamesEnabled
    Specifies whether to collect names in the surveys.

    .PARAMETER RestrictSurveyAccessEnabled
    Specifies whether to restrict survey access.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgDynamics365CustomerVoice -Headers $headers -ReduceSurveyFatigueEnabled $true -ReduceSurveyFatigueDays 30 -CustomDomainEmails @("example.com") -PreventPhishingAttemptsEnabled $false -CollectNamesEnabled $true -RestrictSurveyAccessEnabled $true

    This example enables the Reduce Survey Fatigue feature, sets the number of days to reduce survey fatigue to 30, adds "example.com" as a custom domain email, disables the Prevent Phishing Attempts feature, enables collecting names in the surveys, and restricts survey access for the Office 365 organization.

    .NOTES
    This function sends a POST request to the Office 365 admin API with the specified settings.
    #>
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
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/officeformspro"

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