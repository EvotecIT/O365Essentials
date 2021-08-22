function Set-O365Forms {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $BingImageSearchEnabled,
        [nullable[bool]] $ExternalCollaborationEnabled,
        [nullable[bool]] $ExternalSendFormEnabled,
        [nullable[bool]] $ExternalShareCollaborationEnabled,
        [nullable[bool]] $ExternalShareTemplateEnabled,
        [nullable[bool]] $ExternalShareResultEnabled,
        [nullable[bool]] $InOrgFormsPhishingScanEnabled,
        [nullable[bool]] $InOrgSurveyIncentiveEnabled,
        [nullable[bool]] $RecordIdentityByDefaultEnabled
    )
    # We need to get current settings because it always requires all parameters
    # If we would just provide one parameter it would reset everything else
    $CurrentSettings = Get-O365Forms -Headers $Headers
    $Body = [ordered] @{
        BingImageSearchEnabled            = $CurrentSettings.BingImageSearchEnabled
        ExternalCollaborationEnabled      = $CurrentSettings.ExternalCollaborationEnabled
        ExternalSendFormEnabled           = $CurrentSettings.ExternalSendFormEnabled
        ExternalShareCollaborationEnabled = $CurrentSettings.ExternalShareCollaborationEnabled
        ExternalShareTemplateEnabled      = $CurrentSettings.ExternalShareTemplateEnabled
        ExternalShareResultEnabled        = $CurrentSettings.ExternalShareResultEnabled
        InOrgFormsPhishingScanEnabled     = $CurrentSettings.InOrgFormsPhishingScanEnabled
        InOrgSurveyIncentiveEnabled       = $CurrentSettings.InOrgSurveyIncentiveEnabled
        RecordIdentityByDefaultEnabled    = $CurrentSettings.RecordIdentityByDefaultEnabled
    }
    if ($null -ne $BingImageSearchEnabled) {
        $Body.BingImageSearchEnabled = $BingImageSearchEnabled
    }
    if ($null -ne $ExternalCollaborationEnabled) {
        $Body.ExternalCollaborationEnabled = $ExternalCollaborationEnabled
    }
    if ($null -ne $ExternalSendFormEnabled) {
        $Body.ExternalSendFormEnabled = $ExternalSendFormEnabled
    }
    if ($null -ne $ExternalShareCollaborationEnabled) {
        $Body.ExternalShareCollaborationEnabled = $ExternalShareCollaborationEnabled
    }
    if ($null -ne $ExternalShareTemplateEnabled) {
        $Body.ExternalShareTemplateEnabled = $ExternalShareTemplateEnabled
    }
    if ($null -ne $ExternalShareResultEnabled) {
        $Body.ExternalShareResultEnabled = $ExternalShareResultEnabled
    }
    if ($null -ne $InOrgFormsPhishingScanEnabled) {
        $Body.InOrgFormsPhishingScanEnabled = $InOrgFormsPhishingScanEnabled
    }
    if ($null -ne $InOrgSurveyIncentiveEnabled) {
        $Body.InOrgSurveyIncentiveEnabled = $InOrgSurveyIncentiveEnabled
    }
    if ($null -ne $RecordIdentityByDefaultEnabled) {
        $Body.RecordIdentityByDefaultEnabled = $RecordIdentityByDefaultEnabled
    }

    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/officeforms"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}