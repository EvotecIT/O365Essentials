function Set-O365TeamsTenantWideAppsSettings {
    <#
    .SYNOPSIS
    Updates tenant-wide Teams app settings.

    .DESCRIPTION
    Updates selected tenant-wide app settings used by the Microsoft Teams admin
    center. Before writing, the command reads the current settings and preserves
    the existing appSettingsList. This prevents a boolean-only update from
    accidentally replacing tenant app assignments with an empty list.

    Supplying AppSettingsList explicitly replaces that list. Use -WhatIf to preview
    an update. This command calls an undocumented beta endpoint that Microsoft can
    change without notice.

    .PARAMETER Headers
    Authorization cache returned by Connect-O365Admin. When omitted, the module's
    cached connection is used.

    .PARAMETER Region
    Required regional Teams API route for the tenant. Supported values are emea,
    amer, and apac. The command does not assume a region for write operations.

    .PARAMETER IsAppsEnabled
    Enables or disables Teams apps globally.

    .PARAMETER IsAppsPurchaseEnabled
    Enables or disables app purchases.

    .PARAMETER IsTenantWideAutoInstallEnabled
    Enables or disables tenant-wide automatic app installation.

    .PARAMETER IsExternalAppsEnabledByDefault
    Enables or disables external apps by default.

    .PARAMETER IsSideloadedAppsInteractionEnabled
    Enables or disables interaction with sideloaded apps.

    .PARAMETER IsLicenseBasedPinnedAppsEnabled
    Enables or disables license-based pinned apps.

    .PARAMETER AppSettingsList
    Complete replacement list for app-level settings. Omit this parameter to
    preserve the tenant's current list.

    .EXAMPLE
    $Authorization = Connect-O365Admin -UseWam
    Set-O365TeamsTenantWideAppsSettings -Headers $Authorization -Region emea -IsAppsPurchaseEnabled $false -WhatIf

    Reads the current settings and previews disabling app purchases while preserving
    the current app settings list.

    .EXAMPLE
    $Authorization = Connect-O365Admin -UseWam
    Set-O365TeamsTenantWideAppsSettings -Headers $Authorization -Region emea -IsLicenseBasedPinnedAppsEnabled $true

    Enables license-based pinned apps and preserves the current app settings list.
    #>
    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][ValidateSet('emea', 'amer', 'apac')][string] $Region,
        [ValidateNotNull()][nullable[bool]] $IsAppsEnabled,
        [ValidateNotNull()][nullable[bool]] $IsAppsPurchaseEnabled,
        [ValidateNotNull()][nullable[bool]] $IsTenantWideAutoInstallEnabled,
        [ValidateNotNull()][nullable[bool]] $IsExternalAppsEnabledByDefault,
        [ValidateNotNull()][nullable[bool]] $IsSideloadedAppsInteractionEnabled,
        [ValidateNotNull()][nullable[bool]] $IsLicenseBasedPinnedAppsEnabled,
        [ValidateNotNull()][AllowEmptyCollection()][object[]] $AppSettingsList
    )

    $SettingMap = [ordered] @{
        IsAppsEnabled                       = 'isAppsEnabled'
        IsAppsPurchaseEnabled               = 'isAppsPurchaseEnabled'
        IsTenantWideAutoInstallEnabled      = 'isTenantWideAutoInstallEnabled'
        IsExternalAppsEnabledByDefault      = 'isExternalAppsEnabledByDefault'
        IsSideloadedAppsInteractionEnabled  = 'isSideloadedAppsInteractionEnabled'
        IsLicenseBasedPinnedAppsEnabled     = 'isLicenseBasedPinnedAppsEnabled'
    }
    $SettingParameters = @($SettingMap.Keys) + 'AppSettingsList'
    $HasRequestedChange = $false
    foreach ($ParameterName in $SettingParameters) {
        if ($PSBoundParameters.ContainsKey($ParameterName)) {
            $HasRequestedChange = $true
            break
        }
    }
    if (-not $HasRequestedChange) {
        Write-Warning -Message 'Set-O365TeamsTenantWideAppsSettings - No settings were provided; nothing to update.'
        return
    }

    $Uri = "https://teams.microsoft.com/api/mt/$Region/beta/users/tenantWideAppsSettings"
    $Current = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -ErrorAction Stop
    if ($null -eq $Current) {
        throw 'Set-O365TeamsTenantWideAppsSettings - Current settings could not be read; the update was cancelled.'
    }

    $Body = [ordered] @{}
    foreach ($Property in $Current.PSObject.Properties) {
        $Body[$Property.Name] = $Property.Value
    }
    $CurrentPropertyNames = @($Body.Keys)
    foreach ($Entry in $SettingMap.GetEnumerator()) {
        if ($PSBoundParameters.ContainsKey($Entry.Key)) {
            $Body[$Entry.Value] = [bool] $PSBoundParameters[$Entry.Key]
        }
    }

    if ($PSBoundParameters.ContainsKey('AppSettingsList')) {
        $Body['appSettingsList'] = @($AppSettingsList)
    } elseif ($CurrentPropertyNames -contains 'appSettingsList') {
        if ($null -eq $Current.appSettingsList) {
            throw 'Set-O365TeamsTenantWideAppsSettings - The current appSettingsList was null; the update was cancelled to protect existing app assignments.'
        }
        $Body['appSettingsList'] = @($Current.appSettingsList)
    } else {
        throw 'Set-O365TeamsTenantWideAppsSettings - The current response did not contain appSettingsList; the update was cancelled to protect existing app assignments.'
    }

    $CurrentAppCount = if ($null -eq $Current.appSettingsList) { 0 } else { @($Current.appSettingsList).Count }
    $RequestedAppCount = @($Body.appSettingsList).Count
    $Action = if ($PSBoundParameters.ContainsKey('AppSettingsList')) {
        "Replace the tenant-wide Teams app settings list ($CurrentAppCount -> $RequestedAppCount) and update selected settings"
    } else {
        "Update tenant-wide Teams app settings while preserving $CurrentAppCount app settings"
    }
    if ($PSCmdlet.ShouldProcess($Uri, $Action)) {
        Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body -JsonDepth 20 -Confirm:$false -ErrorAction Stop
    }
}
