function Set-O365OrgForms {
    <#
    .SYNOPSIS
    Configures the settings for Office 365 Forms.

    .DESCRIPTION
    This function allows you to configure various settings for Office 365 Forms. It retrieves the current settings, updates them based on the provided parameters, and then sends the updated settings back to the Office 365 admin API.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER BingImageSearchEnabled
    Specifies whether Bing Image Search should be enabled in Office 365 Forms.

    .PARAMETER ExternalCollaborationEnabled
    Specifies whether external collaboration should be enabled in Office 365 Forms.

    .PARAMETER ExternalSendFormEnabled
    Specifies whether sending forms externally should be enabled in Office 365 Forms.

    .PARAMETER ExternalShareCollaborationEnabled
    Specifies whether external share collaboration should be enabled in Office 365 Forms.

    .PARAMETER ExternalShareTemplateEnabled
    Specifies whether external share template should be enabled in Office 365 Forms.

    .PARAMETER ExternalShareResultEnabled
    Specifies whether external share result should be enabled in Office 365 Forms.

    .PARAMETER InOrgFormsPhishingScanEnabled
    Specifies whether phishing scan for in-organization forms should be enabled in Office 365 Forms.

    .PARAMETER InOrgSurveyIncentiveEnabled
    Specifies whether survey incentive for in-organization forms should be enabled in Office 365 Forms.

    .PARAMETER RecordIdentityByDefaultEnabled
    Specifies whether recording identity by default should be enabled in Office 365 Forms.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgForms -Headers $headers -BingImageSearchEnabled $true -ExternalCollaborationEnabled $false

    This example enables Bing Image Search and disables external collaboration in Office 365 Forms.

    .NOTES
    This function sends a POST request to the Office 365 admin API with the specified settings. It retrieves the current settings, updates them based on the provided parameters, and then sends the updated settings back to the API.
    #>
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
    $CurrentSettings = Get-O365OrgForms -Headers $Headers
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
