function Get-O365MicrosoftTeams {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/skypeteams"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
    <#
    IsSkypeTeamsLicensed   : True
    TenantCategorySettings : {@{TenantSkuCategory=BusinessEnterprise; IsSkypeTeamsEnabled=; Meetups=; FunControl=; Messaging=}, @{TenantSkuCategory=Guest; IsSkypeTeamsEnabled=; Meetups=; FunControl=; Messaging=}}
    Bots                   : @{IsBotsEnabled=; IsSideLoadedBotsEnabled=; BotSettings=System.Object[]; IsExternalAppsEnabledByDefault=}
    Miscellaneous          : @{IsOrganizationTabEnabled=; IsSkypeBusinessInteropEnabled=; IsTBotProactiveMessagingEnabled=}
    Email                  : @{IsEmailIntoChannelsEnabled=; RestrictedSenderList=System.Object[]}
    CloudStorage           : @{Box=; Dropbox=; GoogleDrive=; ShareFile=}
    TeamsOwnedApps         : @{TeamsOwnedAppSettings=System.Object[]}
    TenantOwnedApps        : @{TenantOwnedAppSettings=System.Object[]}
    MigrationStates        : @{EnableAppsMigration=; EnableClientSettingsMigration=; EnableMeetupsMigration=; EnableMessagingMigration=}
    #>
}