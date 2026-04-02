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
        } elseif ($Headers.Contains('PortalWebSession') -and $null -ne $Headers['PortalWebSession']) {
            $UsePortalSession = $true
        }
    }

    function Get-AgentSafeResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            $Result = & $ScriptBlock
            if ($null -eq $Result) {
                New-O365UnavailableResult -Name $ResultName -Area 'Agents settings section' -Description 'The Agents settings section did not return a usable payload.'
            } else {
                $Result
            }
        } catch {
            New-O365UnavailableResult -Name $ResultName -Area 'Agents settings section' -Description 'The Agents settings section did not return a usable payload.' -ErrorMessage $_.Exception.Message
        }
    }

    function Get-AgentSharedSettings {
        $Uri = 'https://admin.cloud.microsoft/fd/addins/api/v2/settings?keys=MetaOSCopilotExtensibilitySettings,AreFirstPartyAppsAllowed,AreThirdPartyAppsAllowed,AreLOBAppsAllowed,AdminRoles,AllowOrgWideSharing'
        Get-AgentSafeResult -ResultName 'SharedSettings' -ScriptBlock { Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders -UsePortalSession:$UsePortalSession }
    }

    function Get-AgentTemplatesBundle {
        [PSCustomObject] @{
            Templates                = Get-AgentSafeResult -ResultName 'Templates' -ScriptBlock { Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/admin/api/agenttemplates/getagenttemplates' -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders -UsePortalSession:$UsePortalSession }
            Policies                 = Get-AgentSafeResult -ResultName 'Policies' -ScriptBlock { Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/admin/api/agenttemplates/getpolicies?expand=true' -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders -UsePortalSession:$UsePortalSession }
            BillingAccounts          = Get-AgentSafeResult -ResultName 'BillingAccounts' -ScriptBlock { Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/admin/api/tenant/billingAccountsWithShell' -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders -UsePortalSession:$UsePortalSession }
            AutoQuotaEnabled         = Get-AgentSafeResult -ResultName 'AutoQuotaEnabled' -ScriptBlock { Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/_api/SPOInternalUseOnly.TenantAdminSettings/AutoQuotaEnabled' -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders -UsePortalSession:$UsePortalSession }
            CustomViewFilterDefaults = Get-AgentSafeResult -ResultName 'CustomViewFilterDefaults' -ScriptBlock { Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/admin/api/tenant/customviewfilterdefaults' -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders -UsePortalSession:$UsePortalSession }
            UserRoles                = Get-AgentSafeResult -ResultName 'UserRoles' -ScriptBlock { Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/admin/api/users/getuserroles' -Headers $Headers -Method POST -Body @{} -AdditionalHeaders $AdditionalHeaders -UsePortalSession:$UsePortalSession }
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
                AllowMicrosoftBuiltAgents = $SettingsObject.areFirstPartyAppsAllowed
                AllowExternalPublisherAgents = $SettingsObject.areThirdPartyAppsAllowed
                AllowOrgBuiltAgents = $SettingsObject.areLOBAppsAllowed
                RequiredAdminRoles = $SettingsObject.adminRoles
                Extensibility = $SettingsObject.metaOSCopilotExtensibilitySettings
                RawSettings = $Settings
            }
        }
        'Sharing' {
            [PSCustomObject] @{
                IsSettingApplicable = $SettingsObject.allowOrgWideSharing.isSettingApplicable
                AssignmentCategory = $SettingsObject.allowOrgWideSharing.userAssignmentCategory
                Members = $SettingsObject.allowOrgWideSharing.members
                RawSettings = $Settings
            }
        }
        'UserAccess' {
            [PSCustomObject] @{
                IsApplicable = $SettingsObject.metaOSCopilotExtensibilitySettings.isCopilotExtensibilityApplicable
                AssignmentCategory = $SettingsObject.metaOSCopilotExtensibilitySettings.userAssignmentCategory
                Members = $SettingsObject.metaOSCopilotExtensibilitySettings.members
                RawSettings = $Settings
            }
        }
    }
}
