function Set-O365AzureEnterpriseAppsUserSettingsAdmin {
    <#
    .SYNOPSIS
    Enables or Disables user consent to enterprise apps in Azure.

    .DESCRIPTION
    This function allows administrators to enable or disable user consent to enterprise apps in Azure. When enabled, users can consent to apps accessing their data. When disabled, only admins can consent to apps.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER UserConsentToAppsEnabled
    Indicates whether user consent to enterprise apps is enabled.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365AzureEnterpriseAppsUserSettingsAdmin -Headers $headers -UserConsentToAppsEnabled $true

    This example enables user consent to enterprise apps.

    .LINK
    https://main.iam.ad.ext.azure.com/api/RequestApprovals/V2/PolicyTemplates
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][bool] $UserConsentToAppsEnabled
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/RequestApprovals/V2/PolicyTemplates"
    #-Body "{`"id`":null,`"requestExpiresInDays`":30,`"notificationsEnabled`":true,`
    #"remindersEnabled`":true,`"approversV2`":{`"user`":[`"e6a8f1cf-0874-4323-a12f-2bf51bb6dfdd`"],`"group`":[],`"role`":[]}}"
    #$Body = @{
    #    Enabled = $UserConsentToAppsEnabled
    #}
    #$null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
}
