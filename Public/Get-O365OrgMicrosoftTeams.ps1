function Get-O365OrgMicrosoftTeams {
    <#
        .SYNOPSIS
        Retrieves Microsoft Teams settings for the organization.
        .DESCRIPTION
        This function retrieves Microsoft Teams settings for the organization from the specified API endpoint using the provided headers.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .EXAMPLE
        Get-O365OrgMicrosoftTeams -Headers $headers
    #>
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
