Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Enterprise Apps admin consent policy commands' {
    It 'translates Graph admin consent reviewers to approver ids' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            [pscustomobject]@{
                isEnabled             = $true
                notifyReviewers       = $true
                remindersEnabled      = $true
                requestDurationInDays = 30
                reviewers             = @(
                    [pscustomobject]@{
                        query     = '/v1.0/users/user-id'
                        queryType = 'MicrosoftGraph'
                    },
                    [pscustomobject]@{
                        query     = '/groups/group-id/transitiveMembers'
                        queryType = 'MicrosoftGraph'
                    },
                    [pscustomobject]@{
                        query     = '/directoryRoles/role-id/members'
                        queryType = 'MicrosoftGraph'
                    }
                )
            }
        }

        $result = Get-O365AzureEnterpriseAppsUserSettingsAdmin -Headers @{ HeadersGraph = @{ Authorization = 'Bearer graph' } }

        $result.isEnabled | Should -BeTrue
        $result.requestExpiresInDays | Should -Be 30
        $result.approvers | Should -Contain 'user-id'
        $result.approversV2.user | Should -Contain 'user-id'
        $result.approversV2.group | Should -Contain 'group-id'
        $result.approversV2.role | Should -Contain 'role-id'
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://graph.microsoft.com/v1.0/policies/adminConsentRequestPolicy' -and
            $RequiredGraphScope -contains 'Policy.Read.All|Policy.ReadWrite.ConsentRequest|Directory.Read.All|Directory.ReadWrite.All'
        } -Times 1 -Exactly
    }

    It 'updates admin consent policy through Graph with normalized reviewers' {
        $script:adminConsentBody = $null
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            if ($Method -eq 'PUT') {
                $script:adminConsentBody = $Body
                return
            }

            [pscustomobject]@{
                isEnabled             = $true
                notifyReviewers       = $true
                remindersEnabled      = $true
                requestDurationInDays = 30
                reviewers             = @(
                    [pscustomobject]@{
                        query     = '/v1.0/users/user-id'
                        queryType = 'MicrosoftGraph'
                    }
                )
            }
        }

        Set-O365AzureEnterpriseAppsUserSettingsAdmin -Headers @{ HeadersGraph = @{ Authorization = 'Bearer graph' } } -IsEnabled $true -RequestExpiresInDays 45

        $script:adminConsentBody.requestDurationInDays | Should -Be 45
        @($script:adminConsentBody.reviewers).Count | Should -Be 1
        $script:adminConsentBody.reviewers[0].query | Should -Be '/users/user-id'
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://graph.microsoft.com/v1.0/policies/adminConsentRequestPolicy' -and
            -not $Method -and
            $RequiredGraphScope -contains 'Policy.Read.All|Policy.ReadWrite.ConsentRequest|Directory.Read.All|Directory.ReadWrite.All'
        } -Times 1 -Exactly
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Method -eq 'PUT' -and
            $Uri -eq 'https://graph.microsoft.com/v1.0/policies/adminConsentRequestPolicy' -and
            $RequiredGraphScope -contains 'Policy.ReadWrite.ConsentRequest|Directory.ReadWrite.All'
        } -Times 1 -Exactly
    }

    It 'uses transitive member reviewer queries for group approvers' {
        $script:adminConsentBody = $null
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            if ($Method -eq 'PUT') {
                $script:adminConsentBody = $Body
                return
            }

            [pscustomobject]@{
                isEnabled             = $true
                notifyReviewers       = $true
                remindersEnabled      = $true
                requestDurationInDays = 30
                reviewers             = @()
            }
        }

        Set-O365AzureEnterpriseAppsUserSettingsAdmin -Headers @{ HeadersGraph = @{ Authorization = 'Bearer graph' } } -GroupApproverId 'group-id'

        $script:adminConsentBody.reviewers[0].query | Should -Be '/groups/group-id/transitiveMembers'
    }

    It 'uses member reviewer queries for role approvers' {
        $script:adminConsentBody = $null
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            if ($Method -eq 'PUT') {
                $script:adminConsentBody = $Body
                return
            }

            [pscustomobject]@{
                isEnabled             = $true
                notifyReviewers       = $true
                remindersEnabled      = $true
                requestDurationInDays = 30
                reviewers             = @()
            }
        }

        Set-O365AzureEnterpriseAppsUserSettingsAdmin -Headers @{ HeadersGraph = @{ Authorization = 'Bearer graph' } } -RoleApproverId 'role-id'

        $script:adminConsentBody.reviewers[0].query | Should -Be '/directoryRoles/role-id/members'
    }

    It 'requires reviewers when enabling the admin consent workflow' {
        Mock -ModuleName O365Essentials Write-Warning
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            if ($Method -eq 'PUT') {
                throw 'PUT should not be called without reviewers'
            }

            [pscustomobject]@{
                isEnabled             = $false
                notifyReviewers       = $true
                remindersEnabled      = $true
                requestDurationInDays = 30
                reviewers             = @()
            }
        }

        Set-O365AzureEnterpriseAppsUserSettingsAdmin -Headers @{ HeadersGraph = @{ Authorization = 'Bearer graph' } } -IsEnabled $true

        Should -Invoke -CommandName Write-Warning -ModuleName O365Essentials -Times 1 -Exactly
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Method -eq 'PUT'
        } -Times 0 -Exactly
    }

    It 'accepts hashtable reviewer objects' {
        $script:adminConsentBody = $null
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            if ($Method -eq 'PUT') {
                $script:adminConsentBody = $Body
                return
            }

            [pscustomobject]@{
                isEnabled             = $true
                notifyReviewers       = $true
                remindersEnabled      = $true
                requestDurationInDays = 30
                reviewers             = @()
            }
        }

        Set-O365AzureEnterpriseAppsUserSettingsAdmin -Headers @{ HeadersGraph = @{ Authorization = 'Bearer graph' } } -Reviewer @{ query = '/v1.0/users/user-id'; queryType = 'MicrosoftGraph' }

        $script:adminConsentBody.reviewers[0].query | Should -Be '/users/user-id'
        $script:adminConsentBody.reviewers[0].queryType | Should -Be 'MicrosoftGraph'
    }
}

Describe 'Microsoft Teams settings setter' {
    BeforeEach {
        $script:teamsBody = $null
        Mock -ModuleName O365Essentials Get-O365OrgMicrosoftTeams -MockWith {
            [pscustomobject]@{
                Email        = [pscustomobject]@{
                    IsEmailIntoChannelsEnabled = [pscustomobject]@{ Value = $true; EnableEditing = $true }
                }
                CloudStorage = [pscustomobject]@{
                    Box         = [pscustomobject]@{ Value = $true; EnableEditing = $true }
                    Dropbox     = [pscustomobject]@{ Value = $true; EnableEditing = $true }
                    GoogleDrive = [pscustomobject]@{ Value = $true; EnableEditing = $true }
                    ShareFile   = [pscustomobject]@{ Value = $true; EnableEditing = $true }
                }
                Bots         = [pscustomobject]@{
                    IsBotsEnabled                  = [pscustomobject]@{ Value = $true; EnableEditing = $true }
                    IsSideLoadedBotsEnabled        = [pscustomobject]@{ Value = $true; EnableEditing = $true }
                    IsExternalAppsEnabledByDefault = [pscustomobject]@{ Value = $false; EnableEditing = $true }
                }
                Miscellaneous = [pscustomobject]@{
                    IsSkypeBusinessInteropEnabled  = [pscustomobject]@{ Value = $true; EnableEditing = $true }
                    IsTBotProactiveMessagingEnabled = [pscustomobject]@{ Value = $true; EnableEditing = $true }
                }
                TenantCategorySettings = @(
                    [pscustomobject]@{
                        TenantSkuCategory = 'BusinessEnterprise'
                        IsSkypeTeamsEnabled = [pscustomobject]@{ Value = $true; EnableEditing = $true }
                    }
                )
            }
        }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            $script:teamsBody = $Body
        }
    }

    It 'updates editable Teams settings and posts the full payload' {
        Set-O365OrgMicrosoftTeams -Headers @{ HeadersO365 = @{ Authorization = 'Bearer token' } } -IsEmailIntoChannelsEnabled $false -CloudStorageBoxEnabled $false

        $script:teamsBody.Email.IsEmailIntoChannelsEnabled.Value | Should -BeFalse
        $script:teamsBody.CloudStorage.Box.Value | Should -BeFalse
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.microsoft.com/admin/api/settings/apps/skypeteams' -and
            $Method -eq 'POST' -and
            $JsonDepth -eq 20
        } -Times 1 -Exactly
    }

    It 'does not post when only the unsupported calendar setting is supplied' {
        Mock -ModuleName O365Essentials Write-Warning

        Set-O365OrgMicrosoftTeams -Headers @{ HeadersO365 = @{ Authorization = 'Bearer token' } } -AllowCalendarSharing $true

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -Times 0 -Exactly
        Should -Invoke -CommandName Write-Warning -ModuleName O365Essentials -ParameterFilter {
            $Message -like 'Set-O365OrgMicrosoftTeams - AllowCalendarSharing is not exposed*'
        } -Times 1 -Exactly
    }

    It 'warns cleanly when a nested Teams setting wrapper is missing' {
        Mock -ModuleName O365Essentials Write-Warning
        Mock -ModuleName O365Essentials Get-O365OrgMicrosoftTeams -MockWith {
            [pscustomobject]@{
                Email        = [pscustomobject]@{}
                CloudStorage = [pscustomobject]@{}
                Bots         = [pscustomobject]@{}
            }
        }

        Set-O365OrgMicrosoftTeams -Headers @{ HeadersO365 = @{ Authorization = 'Bearer token' } } -CloudStorageGoogleDriveEnabled $false

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -Times 0 -Exactly
        Should -Invoke -CommandName Write-Warning -ModuleName O365Essentials -ParameterFilter {
            $Message -eq "Set-O365EditableSettingValue - Setting 'CloudStorage.GoogleDrive' was not found."
        } -Times 1 -Exactly
    }
}

Describe 'Privileged Access settings setter' {
    It 'does not call the API when no setting is supplied' {
        Mock -ModuleName O365Essentials Get-O365OrgPrivilegedAccess
        Mock -ModuleName O365Essentials Invoke-O365Admin
        Mock -ModuleName O365Essentials Write-Warning

        Set-O365OrgPrivilegedAccess

        Should -Invoke -CommandName Get-O365OrgPrivilegedAccess -ModuleName O365Essentials -Times 0 -Exactly
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -Times 0 -Exactly
        Should -Invoke -CommandName Write-Warning -ModuleName O365Essentials -ParameterFilter {
            $Message -eq 'Set-O365OrgPrivilegedAccess - No settings were provided; nothing to update.'
        } -Times 1 -Exactly
    }

    It 'rejects an explicitly bound null enabled setting before reading or writing' {
        Mock -ModuleName O365Essentials Get-O365OrgPrivilegedAccess
        Mock -ModuleName O365Essentials Invoke-O365Admin

        { Set-O365OrgPrivilegedAccess -TenantLockBoxEnabled $null } | Should -Throw

        Should -Invoke -CommandName Get-O365OrgPrivilegedAccess -ModuleName O365Essentials -Times 0 -Exactly
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -Times 0 -Exactly
    }

    It 'requires an admin group when enabling Tenant Lockbox' {
        Mock -ModuleName O365Essentials Get-O365OrgPrivilegedAccess -MockWith {
            [pscustomobject]@{
                EnabledTenantLockbox = $false
                AdminGroup           = ''
                Identity             = $null
            }
        }
        Mock -ModuleName O365Essentials Invoke-O365Admin
        Mock -ModuleName O365Essentials Write-Warning

        Set-O365OrgPrivilegedAccess -Headers @{ HeadersO365 = @{ Authorization = 'Bearer token' } } -TenantLockBoxEnabled $true

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -Times 0 -Exactly
        Should -Invoke -CommandName Write-Warning -ModuleName O365Essentials -ParameterFilter {
            $Message -eq 'Set-O365OrgPrivilegedAccess - AdminGroup is required when Tenant Lockbox is enabled.'
        } -Times 1 -Exactly
    }

    It 'preserves current values for omitted privileged access settings' {
        Mock -ModuleName O365Essentials Get-O365OrgPrivilegedAccess -MockWith {
            [pscustomobject]@{
                EnabledTenantLockbox = $false
                AdminGroup           = ''
                Identity             = $null
            }
        }
        Mock -ModuleName O365Essentials Invoke-O365Admin

        Set-O365OrgPrivilegedAccess -Headers @{ HeadersO365 = @{ Authorization = 'Bearer token' } } -TenantLockBoxEnabled $false -Confirm:$false

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.microsoft.com/admin/api/Settings/security/tenantLockbox' -and
            $Method -eq 'POST' -and
            $Body.EnabledTenantLockbox -eq $false -and
            $Body.AdminGroup -eq '' -and
            $ErrorAction -eq 'Stop'
        } -Times 1 -Exactly
    }

    It 'reads current state but does not write when WhatIf is used' {
        Mock -ModuleName O365Essentials Get-O365OrgPrivilegedAccess -MockWith {
            [pscustomobject]@{
                EnabledTenantLockbox = $false
                AdminGroup           = ''
                Identity             = $null
            }
        }
        Mock -ModuleName O365Essentials Invoke-O365Admin

        Set-O365OrgPrivilegedAccess -TenantLockBoxEnabled $false -WhatIf

        Should -Invoke -CommandName Get-O365OrgPrivilegedAccess -ModuleName O365Essentials -Times 1 -Exactly
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -Times 0 -Exactly
    }

    It 'classifies tenant-wide privileged access writes as high impact' {
        $Metadata = [System.Management.Automation.CommandMetadata]::new(
            (Get-Command Set-O365OrgPrivilegedAccess)
        )

        $Metadata.ConfirmImpact | Should -Be 'High'
    }
}
