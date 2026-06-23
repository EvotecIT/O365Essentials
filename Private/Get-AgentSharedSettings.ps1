function Get-AgentSharedSettings {
    $Uri = 'https://admin.cloud.microsoft/fd/addins/api/v2/settings?keys=MetaOSCopilotExtensibilitySettings,AreFirstPartyAppsAllowed,AreThirdPartyAppsAllowed,AreLOBAppsAllowed,AdminRoles,AllowOrgWideSharing'
    Invoke-O365SectionSafeResult -Section AgentsSettings -ResultName 'SharedSettings' -ScriptBlock { Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders -UsePortalSession:$UsePortalSession }
}
