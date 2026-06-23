function Get-O365AgentSettings {
    <#
    .SYNOPSIS
    Retrieves Agents settings from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal Agents settings such as allowed agent types, sharing, templates,
    and user access configuration.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which Agents settings payload to return.

    .EXAMPLE
    Get-O365AgentSettings

    .EXAMPLE
    Get-O365AgentSettings -Name AllowedAgentTypes
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('All', 'AllowedAgentTypes', 'Sharing', 'Templates', 'UserAccess')][string] $Name = 'All'
    )

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context Agents -PortalHost 'https://admin.cloud.microsoft' -AjaxSessionKey $Headers.AjaxSessionKey -PortalRouteKey $Headers.PortalRouteKey
    $UsePortalSession = $false
    if ($Headers) {
        if ($Headers.Contains('AjaxSessionKey') -and -not [string]::IsNullOrWhiteSpace($Headers['AjaxSessionKey'])) {
            $UsePortalSession = $true
        }
        elseif ($Headers.Contains('PortalWebSession') -and $null -ne $Headers['PortalWebSession']) {
            $UsePortalSession = $true
        }
    }

    if ($Name -eq 'All') {
        [PSCustomObject] @{
            AllowedAgentTypes = Get-O365AgentSettings -Headers $Headers -Name AllowedAgentTypes
            Sharing           = Get-O365AgentSettings -Headers $Headers -Name Sharing
            Templates         = Get-O365AgentSettings -Headers $Headers -Name Templates
            UserAccess        = Get-O365AgentSettings -Headers $Headers -Name UserAccess
        }
        return
    }

    if ($Name -eq 'Templates') {
        Get-AgentTemplatesBundle
        return
    }

    $Settings = Get-AgentSharedSettings
    $SettingsObject = if ($Settings.settings) { $Settings.settings } else { $Settings }

    switch ($Name) {
        'AllowedAgentTypes' {
            [PSCustomObject] @{
                AllowMicrosoftBuiltAgents    = $SettingsObject.areFirstPartyAppsAllowed
                AllowExternalPublisherAgents = $SettingsObject.areThirdPartyAppsAllowed
                AllowOrgBuiltAgents          = $SettingsObject.areLOBAppsAllowed
                RequiredAdminRoles           = $SettingsObject.adminRoles
                Extensibility                = $SettingsObject.metaOSCopilotExtensibilitySettings
                RawSettings                  = $Settings
            }
        }
        'Sharing' {
            [PSCustomObject] @{
                IsSettingApplicable = $SettingsObject.allowOrgWideSharing.isSettingApplicable
                AssignmentCategory  = $SettingsObject.allowOrgWideSharing.userAssignmentCategory
                Members             = $SettingsObject.allowOrgWideSharing.members
                RawSettings         = $Settings
            }
        }
        'UserAccess' {
            [PSCustomObject] @{
                IsApplicable       = $SettingsObject.metaOSCopilotExtensibilitySettings.isCopilotExtensibilityApplicable
                AssignmentCategory = $SettingsObject.metaOSCopilotExtensibilitySettings.userAssignmentCategory
                Members            = $SettingsObject.metaOSCopilotExtensibilitySettings.members
                RawSettings        = $Settings
            }
        }
    }
}
