Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365AgentSettings' {
    It 'uses the shared settings endpoint for AllowedAgentTypes' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            [pscustomobject] @{
                settings = [pscustomobject] @{
                    areFirstPartyAppsAllowed = $true
                    areThirdPartyAppsAllowed = $false
                    areLOBAppsAllowed = $true
                    adminRoles = @('Global Administrator')
                    metaOSCopilotExtensibilitySettings = [pscustomobject] @{ isCopilotExtensibilityApplicable = $true; userAssignmentCategory = 'AllUsers'; members = @() }
                    allowOrgWideSharing = [pscustomobject] @{ isSettingApplicable = $true; userAssignmentCategory = 'AllUsers'; members = @() }
                }
            }
        }
        $Result = Get-O365AgentSettings -Name AllowedAgentTypes
        $Result.AllowMicrosoftBuiltAgents | Should -BeTrue
        $Result.AllowExternalPublisherAgents | Should -BeFalse
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/fd/addins/api/v2/settings?keys=MetaOSCopilotExtensibilitySettings,AreFirstPartyAppsAllowed,AreThirdPartyAppsAllowed,AreLOBAppsAllowed,AdminRoles,AllowOrgWideSharing'
        } -Exactly 1
    }

    It 'builds the templates bundle' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }
        $Result = Get-O365AgentSettings -Name Templates
        $Result.Templates.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/agenttemplates/getagenttemplates'
        $Result.UserRoles.Uri | Should -Be 'https://admin.cloud.microsoft/admin/api/users/getuserroles'
    }

    It 'returns a placeholder when shared settings are unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365AgentSettings -Name AllowedAgentTypes

        $Result.RawSettings.Name | Should -Be 'SharedSettings'
        $Result.RawSettings.DataBacked | Should -BeFalse
    }

    It 'prefers portal session replay when portal session metadata is available' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/'; AjaxSessionKey = 'ajax-key'; 'x-portal-routekey' = 'weu' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            [pscustomobject] @{
                settings = [pscustomobject] @{
                    areFirstPartyAppsAllowed = $true
                    areThirdPartyAppsAllowed = $false
                    areLOBAppsAllowed = $true
                    adminRoles = @()
                    metaOSCopilotExtensibilitySettings = [pscustomobject] @{ isCopilotExtensibilityApplicable = $true; userAssignmentCategory = 'AllUsers'; members = @() }
                    allowOrgWideSharing = [pscustomobject] @{ isSettingApplicable = $true; userAssignmentCategory = 'AllUsers'; members = @() }
                }
            }
        }

        Get-O365AgentSettings -Headers @{ AjaxSessionKey = 'ajax-key'; PortalRouteKey = 'weu'; PortalWebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new() } -Name AllowedAgentTypes

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/fd/addins/api/v2/settings?keys=MetaOSCopilotExtensibilitySettings,AreFirstPartyAppsAllowed,AreThirdPartyAppsAllowed,AreLOBAppsAllowed,AdminRoles,AllowOrgWideSharing' -and
            $UsePortalSession -and
            $AdditionalHeaders.AjaxSessionKey -eq 'ajax-key' -and
            $AdditionalHeaders['x-portal-routekey'] -eq 'weu'
        } -Exactly 1
    }
}
