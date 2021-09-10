function Set-O365AzureEnterpriseAppsUserSettingsAdmin {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][bool] $UserConsentToAppsEnabled
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/RequestApprovals/V2/PolicyTemplates"
    #-Body "{`"id`":null,`"requestExpiresInDays`":30,`"notificationsEnabled`":true,`
    #"remindersEnabled`":true,`"approversV2`":{`"user`":[`"e6a8f1cf-0874-4323-a12f-2bf51bb6dfdd`"],`"group`":[],`"role`":[]}}"
    #$Body = @{
    #    Enabled = $UserConsentToAppsEnabled
    #}
    #$null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
}
