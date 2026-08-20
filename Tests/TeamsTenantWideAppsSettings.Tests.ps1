Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Teams tenant-wide app settings' {
    BeforeEach {
        $script:CurrentSettings = [pscustomobject]@{
            isAppsEnabled                      = $true
            isAppsPurchaseEnabled              = $true
            isTenantWideAutoInstallEnabled     = $false
            isExternalAppsEnabledByDefault     = $true
            isSideloadedAppsInteractionEnabled = $false
            isLicenseBasedPinnedAppsEnabled    = $false
            lobTextColor                       = '#ffffff'
            lobBackground                      = '#000000'
            lobLogo                            = 'logo-data'
            lobLogomark                        = 'logomark-data'
            appSettingsList                    = @(
                [pscustomobject]@{ id = 'app-one'; isEnabled = $true }
                [pscustomobject]@{ id = 'app-two'; isEnabled = $false }
            )
        }
    }

    It 'reads settings from the requested Teams region' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $script:CurrentSettings }
        $Headers = @{ HeadersTeams = @{ Authorization = 'Bearer teams' } }

        $Result = Get-O365TeamsTenantWideAppsSettings -Headers $Headers -Region amer

        $Result.appSettingsList.Count | Should -Be 2
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://teams.microsoft.com/api/mt/amer/beta/users/tenantWideAppsSettings' -and
            $Method -eq 'GET' -and
            $Headers.HeadersTeams.Authorization -eq 'Bearer teams'
        } -Times 1 -Exactly
    }

    It 'does not call the API when no setting is supplied' {
        Mock -ModuleName O365Essentials Invoke-O365Admin
        Mock -ModuleName O365Essentials Write-Warning

        Set-O365TeamsTenantWideAppsSettings -Region emea

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -Times 0 -Exactly
        Should -Invoke -CommandName Write-Warning -ModuleName O365Essentials -ParameterFilter {
            $Message -eq 'Set-O365TeamsTenantWideAppsSettings - No settings were provided; nothing to update.'
        } -Times 1 -Exactly
    }

    It 'merges boolean changes and preserves the current app settings list' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            param($Uri, $Headers, $Method, $Body, $JsonDepth)
            if ($Method -eq 'GET') {
                return $script:CurrentSettings
            }
            [pscustomobject]@{ updated = $true }
        }

        $Result = Set-O365TeamsTenantWideAppsSettings -Region emea -IsAppsPurchaseEnabled $false -Confirm:$false

        $Result.updated | Should -BeTrue
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Method -eq 'GET'
        } -Times 1 -Exactly
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Method -eq 'PUT' -and
            $JsonDepth -eq 20 -and
            $Body.isAppsEnabled -eq $true -and
            $Body.isAppsPurchaseEnabled -eq $false -and
            $Body.isTenantWideAutoInstallEnabled -eq $false -and
            $Body.isExternalAppsEnabledByDefault -eq $true -and
            $Body.isSideloadedAppsInteractionEnabled -eq $false -and
            $Body.isLicenseBasedPinnedAppsEnabled -eq $false -and
            $Body.lobTextColor -eq '#ffffff' -and
            $Body.lobBackground -eq '#000000' -and
            $Body.lobLogo -eq 'logo-data' -and
            $Body.lobLogomark -eq 'logomark-data' -and
            $Body.appSettingsList.Count -eq 2 -and
            $Body.appSettingsList[0].id -eq 'app-one' -and
            $Body.appSettingsList[1].id -eq 'app-two'
        } -Times 1 -Exactly
    }

    It 'replaces app settings only when the list is explicitly supplied' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            param($Uri, $Headers, $Method, $Body)
            if ($Method -eq 'GET') {
                return $script:CurrentSettings
            }
        }

        Set-O365TeamsTenantWideAppsSettings -Region emea -AppSettingsList @() -Confirm:$false

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Method -eq 'PUT' -and
            $Body.Contains('appSettingsList') -and
            $Body.appSettingsList.Count -eq 0
        } -Times 1 -Exactly
    }

    It 'cancels the update when the current app settings list cannot be preserved' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            [pscustomobject]@{ isAppsEnabled = $true }
        }

        { Set-O365TeamsTenantWideAppsSettings -Region emea -IsAppsEnabled $false } |
            Should -Throw '*did not contain appSettingsList*'

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Method -eq 'PUT'
        } -Times 0 -Exactly
    }

    It 'cancels the update when the current app settings list is null' {
        $script:CurrentSettings.appSettingsList = $null
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $script:CurrentSettings }

        { Set-O365TeamsTenantWideAppsSettings -Region emea -IsAppsEnabled $false -Confirm:$false } |
            Should -Throw '*current appSettingsList was null*'

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Method -eq 'PUT'
        } -Times 0 -Exactly
    }

    It 'rejects a null replacement app settings list before reading or writing' {
        Mock -ModuleName O365Essentials Invoke-O365Admin

        { Set-O365TeamsTenantWideAppsSettings -Region emea -AppSettingsList $null -Confirm:$false } |
            Should -Throw

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -Times 0 -Exactly
    }

    It 'rejects explicitly bound null boolean settings before reading or writing' {
        Mock -ModuleName O365Essentials Invoke-O365Admin
        $BooleanParameters = @(
            'IsAppsEnabled'
            'IsAppsPurchaseEnabled'
            'IsTenantWideAutoInstallEnabled'
            'IsExternalAppsEnabledByDefault'
            'IsSideloadedAppsInteractionEnabled'
            'IsLicenseBasedPinnedAppsEnabled'
        )

        foreach ($ParameterName in $BooleanParameters) {
            $Parameters = @{ Region = 'emea'; Confirm = $false }
            $Parameters[$ParameterName] = $null

            { Set-O365TeamsTenantWideAppsSettings @Parameters } | Should -Throw
        }

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -Times 0 -Exactly
    }

    It 'requires an explicit tenant region for write operations' {
        $Region = (Get-Command Set-O365TeamsTenantWideAppsSettings).Parameters['Region']

        $Region.Attributes.Mandatory | Should -Contain $true
    }

    It 'requests terminating error behavior for the PUT operation' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith {
            param($Method)
            if ($Method -eq 'GET') {
                return $script:CurrentSettings
            }
        }

        Set-O365TeamsTenantWideAppsSettings -Region emea -IsAppsEnabled $false -Confirm:$false

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Method -eq 'PUT' -and $ErrorAction -eq 'Stop'
        } -Times 1 -Exactly
    }

    It 'reads current state but does not write when WhatIf is used' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $script:CurrentSettings }

        Set-O365TeamsTenantWideAppsSettings -Region emea -IsAppsEnabled $false -WhatIf

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Method -eq 'GET'
        } -Times 1 -Exactly
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Method -eq 'PUT'
        } -Times 0 -Exactly
    }

    It 'classifies tenant-wide writes as high impact' {
        $Metadata = [System.Management.Automation.CommandMetadata]::new(
            (Get-Command Set-O365TeamsTenantWideAppsSettings)
        )

        $Metadata.ConfirmImpact | Should -Be 'High'
    }
}

Describe 'Teams app settings export contract' {
    It 'exports only the supported Teams settings commands' {
        $Manifest = Test-ModuleManifest -Path "$PSScriptRoot/../O365Essentials.psd1"

        $Manifest.ExportedFunctions.Keys | Should -Contain 'Get-O365TeamsTenantWideAppsSettings'
        $Manifest.ExportedFunctions.Keys | Should -Contain 'Set-O365TeamsTenantWideAppsSettings'
        $Manifest.ExportedFunctions.Keys | Should -Not -Contain 'Get-O365UnifiedAppsSettings'
        $Manifest.ExportedFunctions.Keys | Should -Not -Contain 'Set-O365SubstrateAuth'
    }
}
