function Set-O365OrgMicrosoftTeams {
    <#
    .SYNOPSIS
    Configures Microsoft Teams settings for an Office 365 organization.

    .DESCRIPTION
    This function allows you to configure the Microsoft Teams settings for your Office 365 organization. 
    It sends a POST request to the Office 365 admin API with the specified settings.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER Settings
    Full settings payload returned by Get-O365OrgMicrosoftTeams. When supplied,
    the payload is submitted as-is.

    .PARAMETER IsEmailIntoChannelsEnabled
    Enables or disables email into Teams channels when editable by the tenant.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365OrgMicrosoftTeams -Headers $headers -IsEmailIntoChannelsEnabled $true

    This example enables email into Teams channels.

    .NOTES
    https://admin.microsoft.com/#/Settings/Services/:/Settings/L1/SkypeTeams
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [alias('InputObject')] $Settings,
        [nullable[bool]] $AllowCalendarSharing,
        [nullable[bool]] $IsEmailIntoChannelsEnabled,
        [nullable[bool]] $IsBotsEnabled,
        [nullable[bool]] $IsSideLoadedBotsEnabled,
        [nullable[bool]] $IsExternalAppsEnabledByDefault,
        [nullable[bool]] $CloudStorageBoxEnabled,
        [nullable[bool]] $CloudStorageDropboxEnabled,
        [nullable[bool]] $CloudStorageGoogleDriveEnabled,
        [nullable[bool]] $CloudStorageShareFileEnabled,
        [nullable[bool]] $IsSkypeBusinessInteropEnabled,
        [nullable[bool]] $IsTBotProactiveMessagingEnabled,
        [nullable[bool]] $IsSkypeTeamsEnabled,
        [switch] $PassThru
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/apps/skypeteams"

    $Body = if ($PSBoundParameters.ContainsKey('Settings')) {
        $Settings
    } else {
        Get-O365OrgMicrosoftTeams -Headers $Headers
    }

    if (-not $Body) {
        Write-Warning -Message 'Set-O365OrgMicrosoftTeams - Current Microsoft Teams settings could not be read.'
        return
    }

    $Changed = $PSBoundParameters.ContainsKey('Settings')
    if ($PSBoundParameters.ContainsKey('AllowCalendarSharing')) {
        Write-Warning -Message 'Set-O365OrgMicrosoftTeams - AllowCalendarSharing is not exposed by the current Microsoft Teams settings payload and was not changed.'
    }
    if ($PSBoundParameters.ContainsKey('IsEmailIntoChannelsEnabled')) {
        $Changed = (Set-O365EditableSettingValue -Setting $Body.Email.IsEmailIntoChannelsEnabled -Value ([bool] $IsEmailIntoChannelsEnabled) -Name 'Email.IsEmailIntoChannelsEnabled') -or $Changed
    }
    if ($PSBoundParameters.ContainsKey('IsBotsEnabled')) {
        $Changed = (Set-O365EditableSettingValue -Setting $Body.Bots.IsBotsEnabled -Value ([bool] $IsBotsEnabled) -Name 'Bots.IsBotsEnabled') -or $Changed
    }
    if ($PSBoundParameters.ContainsKey('IsSideLoadedBotsEnabled')) {
        $Changed = (Set-O365EditableSettingValue -Setting $Body.Bots.IsSideLoadedBotsEnabled -Value ([bool] $IsSideLoadedBotsEnabled) -Name 'Bots.IsSideLoadedBotsEnabled') -or $Changed
    }
    if ($PSBoundParameters.ContainsKey('IsExternalAppsEnabledByDefault')) {
        $Changed = (Set-O365EditableSettingValue -Setting $Body.Bots.IsExternalAppsEnabledByDefault -Value ([bool] $IsExternalAppsEnabledByDefault) -Name 'Bots.IsExternalAppsEnabledByDefault') -or $Changed
    }
    if ($PSBoundParameters.ContainsKey('CloudStorageBoxEnabled')) {
        $Changed = (Set-O365EditableSettingValue -Setting $Body.CloudStorage.Box -Value ([bool] $CloudStorageBoxEnabled) -Name 'CloudStorage.Box') -or $Changed
    }
    if ($PSBoundParameters.ContainsKey('CloudStorageDropboxEnabled')) {
        $Changed = (Set-O365EditableSettingValue -Setting $Body.CloudStorage.Dropbox -Value ([bool] $CloudStorageDropboxEnabled) -Name 'CloudStorage.Dropbox') -or $Changed
    }
    if ($PSBoundParameters.ContainsKey('CloudStorageGoogleDriveEnabled')) {
        $Changed = (Set-O365EditableSettingValue -Setting $Body.CloudStorage.GoogleDrive -Value ([bool] $CloudStorageGoogleDriveEnabled) -Name 'CloudStorage.GoogleDrive') -or $Changed
    }
    if ($PSBoundParameters.ContainsKey('CloudStorageShareFileEnabled')) {
        $Changed = (Set-O365EditableSettingValue -Setting $Body.CloudStorage.ShareFile -Value ([bool] $CloudStorageShareFileEnabled) -Name 'CloudStorage.ShareFile') -or $Changed
    }
    if ($PSBoundParameters.ContainsKey('IsSkypeBusinessInteropEnabled')) {
        $Changed = (Set-O365EditableSettingValue -Setting $Body.Miscellaneous.IsSkypeBusinessInteropEnabled -Value ([bool] $IsSkypeBusinessInteropEnabled) -Name 'Miscellaneous.IsSkypeBusinessInteropEnabled') -or $Changed
    }
    if ($PSBoundParameters.ContainsKey('IsTBotProactiveMessagingEnabled')) {
        $Changed = (Set-O365EditableSettingValue -Setting $Body.Miscellaneous.IsTBotProactiveMessagingEnabled -Value ([bool] $IsTBotProactiveMessagingEnabled) -Name 'Miscellaneous.IsTBotProactiveMessagingEnabled') -or $Changed
    }
    if ($PSBoundParameters.ContainsKey('IsSkypeTeamsEnabled')) {
        foreach ($Category in @($Body.TenantCategorySettings)) {
            $Changed = (Set-O365EditableSettingValue -Setting $Category.IsSkypeTeamsEnabled -Value ([bool] $IsSkypeTeamsEnabled) -Name "TenantCategorySettings[$($Category.TenantSkuCategory)].IsSkypeTeamsEnabled") -or $Changed
        }
    }

    if (-not $Changed) {
        Write-Warning -Message 'Set-O365OrgMicrosoftTeams - No supported Microsoft Teams setting was changed.'
        return
    }

    if ($PSCmdlet.ShouldProcess($Uri, 'Update Microsoft Teams settings')) {
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body -JsonDepth 20
        if ($PassThru) {
            $Output
        }
    }
}
