Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force
. "$PSScriptRoot/../Private/Get-O365OAuthToken.ps1"

Describe 'Connect-O365Admin portal token' {
    BeforeEach {
        InModuleScope O365Essentials {
            $script:AuthorizationO365Cache = $null
        }
        foreach ($EnvironmentName in @(
                'O365ESSENTIALS_PORTAL_ROOT_AUTH_TOKEN',
                'O365ESSENTIALS_PORTAL_SPA_AUTH_COOKIE',
                'O365ESSENTIALS_PORTAL_OIDC_AUTH_COOKIE',
                'O365ESSENTIALS_PORTAL_AJAX_SESSION_KEY',
                'O365ESSENTIALS_PORTAL_SESSION_ID',
                'O365ESSENTIALS_PORTAL_TENANT_ID',
                'O365ESSENTIALS_PORTAL_ROUTE_KEY',
                'O365ESSENTIALS_PORTAL_USERNAME',
                'O365ESSENTIALS_PORTAL_SKIP_BOOTSTRAP',
                'O365ESSENTIALS_PORTAL_CLEAR_AFTER_READ'
            )) {
            [Environment]::SetEnvironmentVariable($EnvironmentName, $null, 'Process')
        }
    }

    AfterEach {
        foreach ($EnvironmentName in @(
                'O365ESSENTIALS_PORTAL_ROOT_AUTH_TOKEN',
                'O365ESSENTIALS_PORTAL_SPA_AUTH_COOKIE',
                'O365ESSENTIALS_PORTAL_OIDC_AUTH_COOKIE',
                'O365ESSENTIALS_PORTAL_AJAX_SESSION_KEY',
                'O365ESSENTIALS_PORTAL_SESSION_ID',
                'O365ESSENTIALS_PORTAL_TENANT_ID',
                'O365ESSENTIALS_PORTAL_ROUTE_KEY',
                'O365ESSENTIALS_PORTAL_USERNAME',
                'O365ESSENTIALS_PORTAL_SKIP_BOOTSTRAP',
                'O365ESSENTIALS_PORTAL_CLEAR_AFTER_READ'
            )) {
            [Environment]::SetEnvironmentVariable($EnvironmentName, $null, 'Process')
        }
    }

    It 'requests portal token using resource parameter' {
        $cred = New-Object System.Management.Automation.PSCredential('user',(ConvertTo-SecureString 'pass' -AsPlainText -Force))
        Mock -ModuleName O365Essentials Get-O365OAuthToken -MockWith {
            param($Tenant,$Scope,$Resource,$ClientId,$Credential,$RefreshToken,$Device,$ClientSecret,$Certificate,$CertificatePassword)
            [pscustomobject]@{access_token='tok'; refresh_token='ref'}
        }
        Connect-O365Admin -Credential $cred | Out-Null
        Assert-MockCalled Get-O365OAuthToken -ModuleName O365Essentials -ParameterFilter { $Resource -eq '74658136-14ec-4630-ad9b-26e160ff0fc6' } -Exactly 1
    }

    It 'falls back to portal resource token when admin.microsoft.com scope fails' {
        $cred = New-Object System.Management.Automation.PSCredential('user',(ConvertTo-SecureString 'pass' -AsPlainText -Force))
        Mock -ModuleName O365Essentials ConvertFrom-JSONWebToken -MockWith {
            [pscustomobject]@{
                tid = 'tenant-id'
                upn = 'user@contoso.com'
            }
        }
        Mock -ModuleName O365Essentials Get-O365OAuthToken -MockWith {
            param($Tenant,$Scope,$Resource,$ClientId,$Credential,$RefreshToken,$Device,$ClientSecret,$Certificate,$CertificatePassword)
            if ($Scope -eq 'https://graph.microsoft.com/.default offline_access') {
                return [pscustomobject]@{
                    access_token  = 'graph-token'
                    refresh_token = 'refresh-token'
                    id_token      = 'header.payload.signature'
                }
            }
            if ($Scope -eq 'https://admin.microsoft.com/.default offline_access') {
                throw 'admin scope failed'
            }
            if ($Resource -eq '74658136-14ec-4630-ad9b-26e160ff0fc6') {
                return [pscustomobject]@{
                    access_token = 'portal-token'
                }
            }
            if ($Scope -eq 'https://api.spaces.skype.com/.default offline_access') {
                return [pscustomobject]@{
                    access_token = 'teams-token'
                }
            }
            if ($Scope -eq 'https://management.azure.com/.default offline_access') {
                return [pscustomobject]@{
                    access_token = 'arm-token'
                }
            }
            throw "Unexpected token request: Scope=$Scope Resource=$Resource"
        }

        $result = Connect-O365Admin -Credential $cred

        $result.AccessTokenO365 | Should -Be 'portal-token'
        $result.AccessTokenAzure | Should -Be 'portal-token'
        Assert-MockCalled Get-O365OAuthToken -ModuleName O365Essentials -ParameterFilter { $Scope -eq 'https://admin.microsoft.com/.default offline_access' } -Exactly 1
        Assert-MockCalled Get-O365OAuthToken -ModuleName O365Essentials -ParameterFilter { $Resource -eq '74658136-14ec-4630-ad9b-26e160ff0fc6' } -Exactly 1
    }

    It 'falls back to device auth when the localhost listener cannot bind' {
        $cred = New-Object System.Management.Automation.PSCredential('user',(ConvertTo-SecureString 'pass' -AsPlainText -Force))
        Mock -ModuleName O365Essentials ConvertFrom-JSONWebToken -MockWith {
            [pscustomobject]@{
                tid = 'tenant-id'
                upn = 'user@contoso.com'
            }
        }
        Mock -ModuleName O365Essentials Get-O365OAuthToken -MockWith {
            param($Tenant,$Scope,$Resource,$ClientId,$Credential,$RefreshToken,$Device,$ClientSecret,$Certificate,$CertificatePassword)
            if ($Scope -eq 'https://graph.microsoft.com/.default offline_access' -and -not $Device) {
                throw "Exception calling `"Start`" with `"0`" argument(s): `"Failed to listen on prefix 'http://localhost:8400/' because it conflicts with an existing registration on the machine.`""
            }
            if ($Scope -eq 'https://graph.microsoft.com/.default offline_access' -and $Device) {
                return [pscustomobject]@{
                    access_token  = 'graph-token'
                    refresh_token = 'refresh-token'
                    id_token      = 'header.payload.signature'
                }
            }
            if ($Scope -eq 'https://admin.microsoft.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'admin-token' }
            }
            if ($Scope -eq 'https://api.spaces.skype.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'teams-token' }
            }
            if ($Resource -eq '74658136-14ec-4630-ad9b-26e160ff0fc6') {
                return [pscustomobject]@{ access_token = 'portal-token' }
            }
            if ($Scope -eq 'https://management.azure.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'arm-token' }
            }
            if ($Resource -eq 'https://substrate.office.com') {
                return [pscustomobject]@{ access_token = 'substrate-token' }
            }
            throw "Unexpected token request: Scope=$Scope Resource=$Resource Device=$Device"
        }

        $result = Connect-O365Admin -Credential $cred

        $result.AccessTokenGraph | Should -Be 'graph-token'
        Assert-MockCalled Get-O365OAuthToken -ModuleName O365Essentials -ParameterFilter {
            $Scope -eq 'https://graph.microsoft.com/.default offline_access' -and -not $Device
        } -Exactly 1
        Assert-MockCalled Get-O365OAuthToken -ModuleName O365Essentials -ParameterFilter {
            $Scope -eq 'https://graph.microsoft.com/.default offline_access' -and $Device
        } -Exactly 1
    }

    It 'uses bundled MSAL WAM tokens without requiring a refresh token' {
        Mock -ModuleName O365Essentials ConvertFrom-JSONWebToken -MockWith {
            [pscustomobject]@{
                tid = 'tenant-id'
                upn = 'user@contoso.com'
            }
        }
        Mock -ModuleName O365Essentials Get-O365BrokerAccessToken -MockWith {
            param($Tenant, $ResourceUrl, $Scope, $Account, $ForcePrompt)
            $Target = if ($ResourceUrl) { $ResourceUrl } else { $Scope }
            [pscustomobject]@{
                access_token = "token:$Target"
                expires_on   = ([datetime]::UtcNow).AddHours(1)
                tenant_id    = 'tenant-id'
                account      = 'user@contoso.com'
            }
        }
        Mock -ModuleName O365Essentials Get-O365OAuthToken -MockWith { throw 'legacy OAuth path should not be used' }

        $result = Connect-O365Admin -UseWam -Tenant 'tenant-id'

        $result.AuthenticationMode | Should -Be 'WAM'
        $result.RefreshToken | Should -BeNullOrEmpty
        $result.AccessTokenGraph | Should -Be 'token:https://graph.microsoft.com/'
        $result.AccessTokenO365 | Should -Be 'token:https://admin.microsoft.com/'
        $result.HeadersO365.Authorization | Should -Be 'Bearer token:https://admin.microsoft.com/'
        Assert-MockCalled Get-O365OAuthToken -ModuleName O365Essentials -Exactly 0
        Assert-MockCalled Get-O365BrokerAccessToken -ModuleName O365Essentials -ParameterFilter {
            $ResourceUrl -eq 'https://admin.microsoft.com/' -and $Account -eq 'user@contoso.com'
        } -Exactly 1
    }

    It 'passes credential username to the first WAM token request' {
        $cred = New-Object System.Management.Automation.PSCredential('seed@contoso.com',(ConvertTo-SecureString 'pass' -AsPlainText -Force))
        Mock -ModuleName O365Essentials ConvertFrom-JSONWebToken -MockWith {
            [pscustomobject]@{
                tid = 'tenant-id'
                upn = 'seed@contoso.com'
            }
        }
        Mock -ModuleName O365Essentials Get-O365BrokerAccessToken -MockWith {
            param($Tenant, $ResourceUrl, $Scope, $Account, $ForcePrompt)
            $Target = if ($ResourceUrl) { $ResourceUrl } else { $Scope }
            [pscustomobject]@{
                access_token = "token:$Target"
                expires_on   = ([datetime]::UtcNow).AddHours(1)
                tenant_id    = 'tenant-id'
                account      = if ($Account) { $Account } else { 'seed@contoso.com' }
            }
        }
        Mock -ModuleName O365Essentials Get-O365OAuthToken -MockWith { throw 'legacy OAuth path should not be used' }

        $result = Connect-O365Admin -UseWam -Credential $cred -Tenant 'tenant-id'

        $result.UserName | Should -Be 'seed@contoso.com'
        Assert-MockCalled Get-O365BrokerAccessToken -ModuleName O365Essentials -ParameterFilter {
            $ResourceUrl -eq 'https://graph.microsoft.com/' -and $Account -eq 'seed@contoso.com'
        } -Exactly 1
    }

    It 'honors explicit WAM refresh when an expired OAuth cache exists' {
        InModuleScope O365Essentials {
            $script:AuthorizationO365Cache = [ordered] @{
                Credential         = $null
                ClientId           = $null
                ClientSecret       = $null
                Certificate        = $null
                CertificatePassword = $null
                AuthenticationMode = 'OAuth'
                UserName           = 'old@contoso.com'
                Tenant             = 'tenant-id'
                Subscription       = $null
                RefreshToken       = 'old-refresh-token'
                ExpiresOnUTC       = ([datetime]::UtcNow).AddMinutes(-5)
            }
        }
        Mock -ModuleName O365Essentials ConvertFrom-JSONWebToken -MockWith {
            [pscustomobject]@{
                tid = 'tenant-id'
                upn = 'user@contoso.com'
            }
        }
        Mock -ModuleName O365Essentials Get-O365BrokerAccessToken -MockWith {
            param($Tenant, $ResourceUrl, $Scope, $Account, $ForcePrompt)
            $Target = if ($ResourceUrl) { $ResourceUrl } else { $Scope }
            [pscustomobject]@{
                access_token = "token:$Target"
                expires_on   = ([datetime]::UtcNow).AddHours(1)
                tenant_id    = 'tenant-id'
                account      = 'user@contoso.com'
            }
        }
        Mock -ModuleName O365Essentials Get-O365OAuthToken -MockWith { throw 'legacy OAuth path should not be used' }

        $result = Connect-O365Admin -UseWam -ForceRefresh

        $result.AuthenticationMode | Should -Be 'WAM'
        $result.UserName | Should -Be 'user@contoso.com'
        Assert-MockCalled Get-O365OAuthToken -ModuleName O365Essentials -Exactly 0
        Assert-MockCalled Get-O365BrokerAccessToken -ModuleName O365Essentials -ParameterFilter {
            $ResourceUrl -eq 'https://graph.microsoft.com/' -and $ForcePrompt -and [string]::IsNullOrWhiteSpace($Account)
        } -Exactly 1
    }

    It 'uses the cached WAM username to refresh an existing WAM connection' {
        InModuleScope O365Essentials {
            $script:AuthorizationO365Cache = [ordered] @{
                Credential         = $null
                ClientId           = $null
                ClientSecret       = $null
                Certificate        = $null
                CertificatePassword = $null
                AuthenticationMode = 'WAM'
                UserName           = 'cached@contoso.com'
                Tenant             = 'tenant-id'
                Subscription       = $null
                RefreshToken       = $null
                ExpiresOnUTC       = ([datetime]::UtcNow).AddMinutes(-5)
            }
        }
        Mock -ModuleName O365Essentials ConvertFrom-JSONWebToken -MockWith {
            [pscustomobject]@{
                tid = 'tenant-id'
                upn = 'cached@contoso.com'
            }
        }
        Mock -ModuleName O365Essentials Get-O365BrokerAccessToken -MockWith {
            param($Tenant, $ResourceUrl, $Scope, $Account, $ForcePrompt)
            $Target = if ($ResourceUrl) { $ResourceUrl } else { $Scope }
            [pscustomobject]@{
                access_token = "token:$Target"
                expires_on   = ([datetime]::UtcNow).AddHours(1)
                tenant_id    = 'tenant-id'
                account      = if ($Account) { $Account } else { 'cached@contoso.com' }
            }
        }
        Mock -ModuleName O365Essentials Get-O365OAuthToken -MockWith { throw 'legacy OAuth path should not be used' }

        $result = Connect-O365Admin -ForceRefresh

        $result.AuthenticationMode | Should -Be 'WAM'
        $result.UserName | Should -Be 'cached@contoso.com'
        Assert-MockCalled Get-O365BrokerAccessToken -ModuleName O365Essentials -ParameterFilter {
            $ResourceUrl -eq 'https://graph.microsoft.com/' -and $Account -eq 'cached@contoso.com'
        } -Exactly 1
    }

    It 'prefers an explicit WAM credential over an expired cached WAM username' {
        $cred = New-Object System.Management.Automation.PSCredential('new@contoso.com',(ConvertTo-SecureString 'pass' -AsPlainText -Force))
        InModuleScope O365Essentials {
            $script:AuthorizationO365Cache = [ordered] @{
                Credential          = New-Object System.Management.Automation.PSCredential('old@contoso.com',(ConvertTo-SecureString 'pass' -AsPlainText -Force))
                ClientId            = $null
                ClientSecret        = $null
                Certificate         = $null
                CertificatePassword = $null
                AuthenticationMode  = 'WAM'
                UserName            = 'old@contoso.com'
                Tenant              = 'tenant-id'
                Subscription        = $null
                RefreshToken        = $null
                ExpiresOnUTC        = ([datetime]::UtcNow).AddMinutes(-5)
            }
        }
        Mock -ModuleName O365Essentials ConvertFrom-JSONWebToken -MockWith {
            [pscustomobject]@{
                tid = 'tenant-id'
                upn = 'new@contoso.com'
            }
        }
        Mock -ModuleName O365Essentials Get-O365BrokerAccessToken -MockWith {
            param($Tenant, $ResourceUrl, $Scope, $Account, $ForcePrompt)
            $Target = if ($ResourceUrl) { $ResourceUrl } else { $Scope }
            [pscustomobject]@{
                access_token = "token:$Target"
                expires_on   = ([datetime]::UtcNow).AddHours(1)
                tenant_id    = 'tenant-id'
                account      = if ($Account) { $Account } else { 'new@contoso.com' }
            }
        }
        Mock -ModuleName O365Essentials Get-O365OAuthToken -MockWith { throw 'legacy OAuth path should not be used' }

        $result = Connect-O365Admin -UseWam -Credential $cred -ForceRefresh

        $result.AuthenticationMode | Should -Be 'WAM'
        $result.UserName | Should -Be 'new@contoso.com'
        Assert-MockCalled Get-O365BrokerAccessToken -ModuleName O365Essentials -ParameterFilter {
            $ResourceUrl -eq 'https://graph.microsoft.com/' -and $Account -eq 'new@contoso.com'
        } -Exactly 1
    }

    It 'tries the substrate.office.com resource before legacy substrate audiences' {
        $cred = New-Object System.Management.Automation.PSCredential('user',(ConvertTo-SecureString 'pass' -AsPlainText -Force))
        $script:attempts = [System.Collections.Generic.List[string]]::new()
        Mock -ModuleName O365Essentials ConvertFrom-JSONWebToken -MockWith {
            [pscustomobject]@{
                tid = 'tenant-id'
                upn = 'user@contoso.com'
            }
        }
        Mock -ModuleName O365Essentials Get-O365OAuthToken -MockWith {
            param($Tenant,$Scope,$Resource,$ClientId,$Credential,$RefreshToken,$Device,$ClientSecret,$Certificate,$CertificatePassword)
            if ($Scope -eq 'https://graph.microsoft.com/.default offline_access') {
                return [pscustomobject]@{
                    access_token  = 'graph-token'
                    refresh_token = 'refresh-token'
                    id_token      = 'header.payload.signature'
                }
            }
            if ($Scope -eq 'https://admin.microsoft.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'admin-token' }
            }
            if ($Scope -eq 'https://api.spaces.skype.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'teams-token' }
            }
            if ($Resource -eq '74658136-14ec-4630-ad9b-26e160ff0fc6') {
                return [pscustomobject]@{ access_token = 'portal-token' }
            }
            if ($Scope -eq 'https://management.azure.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'arm-token' }
            }

            if ($Resource) {
                $script:attempts.Add("resource:$Resource") | Out-Null
            } elseif ($Scope) {
                $script:attempts.Add("scope:$Scope") | Out-Null
            }

            if ($Resource -eq 'https://substrate.office.com') {
                return [pscustomobject]@{ access_token = 'substrate-token' }
            }

            throw "Unexpected token request: Scope=$Scope Resource=$Resource"
        }

        $result = Connect-O365Admin -Credential $cred

        $result.AccessTokenSubstrate | Should -Be 'substrate-token'
        $script:attempts[0] | Should -Be 'resource:https://substrate.office.com'
    }

    It 'preserves portal session metadata when refreshing an existing connection object' {
        $cred = New-Object System.Management.Automation.PSCredential('user',(ConvertTo-SecureString 'pass' -AsPlainText -Force))
        $portalWebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
        Mock -ModuleName O365Essentials ConvertFrom-JSONWebToken -MockWith {
            [pscustomobject]@{
                tid = 'tenant-id'
                upn = 'user@contoso.com'
            }
        }
        Mock -ModuleName O365Essentials Get-O365OAuthToken -MockWith {
            param($Tenant,$Scope,$Resource,$ClientId,$Credential,$RefreshToken,$Device,$ClientSecret,$Certificate,$CertificatePassword)
            if ($Scope -eq 'https://graph.microsoft.com/.default offline_access') {
                return [pscustomobject]@{
                    access_token  = 'graph-token'
                    refresh_token = 'refresh-token'
                    id_token      = 'header.payload.signature'
                }
            }
            if ($Scope -eq 'https://admin.microsoft.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'admin-token' }
            }
            if ($Scope -eq 'https://api.spaces.skype.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'teams-token' }
            }
            if ($Resource -eq '74658136-14ec-4630-ad9b-26e160ff0fc6') {
                return [pscustomobject]@{ access_token = 'portal-token' }
            }
            if ($Scope -eq 'https://management.azure.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'arm-token' }
            }
            if ($Resource -eq 'https://substrate.office.com') {
                return [pscustomobject]@{ access_token = 'substrate-token' }
            }
        }

        $result = Connect-O365Admin -Headers ([ordered] @{
                Credential       = $cred
                ExpiresOnUTC     = (Get-Date).AddMinutes(-1)
                RefreshToken     = 'refresh-token'
                Tenant           = 'tenant-id'
                PortalWebSession = $portalWebSession
                AjaxSessionKey   = 'ajax-key'
                PortalRouteKey   = 'weu'
                HeadersPortal    = @{ AjaxSessionKey = 'ajax-key' }
            })

        $result.PortalWebSession | Should -Be $portalWebSession
        $result.AjaxSessionKey | Should -Be 'ajax-key'
        $result.PortalRouteKey | Should -Be 'weu'
        $result.HeadersPortal.AjaxSessionKey | Should -Be 'ajax-key'
    }

    It 'attaches portal session state to a valid cached connection without refreshing tokens' {
        $portalWebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
        $cachedHeaders = [ordered] @{
            ExpiresOnUTC = (Get-Date).AddMinutes(10)
            UserName     = 'user@contoso.com'
            HeadersO365  = @{ Authorization = 'Bearer o365' }
        }
        Mock -ModuleName O365Essentials Get-O365OAuthToken -MockWith { throw 'should not refresh' }
        Mock -ModuleName O365Essentials Set-O365PortalSession -MockWith {
            param($Headers, $WebSession, $SkipBootstrap)
            [ordered] @{
                HeadersO365      = $Headers.HeadersO365
                PortalWebSession = $WebSession
                SkipBootstrap    = [bool] $SkipBootstrap
            }
        }

        $result = Connect-O365Admin -Headers $cachedHeaders -PortalAttachWebSession $portalWebSession -SkipPortalBootstrap

        $result.PortalWebSession | Should -Be $portalWebSession
        $result.SkipBootstrap | Should -BeTrue
        Assert-MockCalled Get-O365OAuthToken -ModuleName O365Essentials -Exactly 0
        Assert-MockCalled Set-O365PortalSession -ModuleName O365Essentials -ParameterFilter {
            $Headers -eq $cachedHeaders -and
            $WebSession -eq $portalWebSession -and
            $SkipBootstrap
        } -Exactly 1
    }

    It 'attaches portal cookie state during a fresh connect through the same command' {
        $cred = New-Object System.Management.Automation.PSCredential('user',(ConvertTo-SecureString 'pass' -AsPlainText -Force))
        Mock -ModuleName O365Essentials ConvertFrom-JSONWebToken -MockWith {
            [pscustomobject]@{
                tid = 'tenant-id'
                upn = 'user@contoso.com'
            }
        }
        Mock -ModuleName O365Essentials Get-O365OAuthToken -MockWith {
            param($Tenant,$Scope,$Resource,$ClientId,$Credential,$RefreshToken,$Device,$ClientSecret,$Certificate,$CertificatePassword)
            if ($Scope -eq 'https://graph.microsoft.com/.default offline_access') {
                return [pscustomobject]@{
                    access_token  = 'graph-token'
                    refresh_token = 'refresh-token'
                    id_token      = 'header.payload.signature'
                }
            }
            if ($Scope -eq 'https://admin.microsoft.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'admin-token' }
            }
            if ($Scope -eq 'https://api.spaces.skype.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'teams-token' }
            }
            if ($Resource -eq '74658136-14ec-4630-ad9b-26e160ff0fc6') {
                return [pscustomobject]@{ access_token = 'portal-token' }
            }
            if ($Scope -eq 'https://management.azure.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'arm-token' }
            }
            if ($Resource -eq 'https://substrate.office.com') {
                return [pscustomobject]@{ access_token = 'substrate-token' }
            }
        }
        Mock -ModuleName O365Essentials Set-O365PortalSession -MockWith {
            param($Headers, $RootAuthToken, $OIDCAuthCookie, $AjaxSessionKey, $SessionId, $TenantId, $Username, $SkipBootstrap)
            [ordered] @{
                AccessTokenGraph = $Headers.AccessTokenGraph
                PortalSeed       = $RootAuthToken
                OIDCSeed         = $OIDCAuthCookie
                AjaxSessionKey   = $AjaxSessionKey
                SessionId        = $SessionId
                PortalTenantId   = $TenantId
                PortalUserId     = $Username
                SkipBootstrap    = [bool] $SkipBootstrap
            }
        }

        $result = Connect-O365Admin -Credential $cred -PortalAttachRootAuthToken 'root-cookie' -PortalAttachOIDCAuthCookie 'oidc-cookie' -PortalAttachAjaxSessionKey 'ajax-key' -PortalAttachSessionId 'session-123' -PortalAttachTenantId 'tenant-1234' -PortalAttachUserName 'user@contoso.com' -SkipPortalBootstrap

        $result.AccessTokenGraph | Should -Be 'graph-token'
        $result.PortalSeed | Should -Be 'root-cookie'
        $result.OIDCSeed | Should -Be 'oidc-cookie'
        $result.AjaxSessionKey | Should -Be 'ajax-key'
        $result.SessionId | Should -Be 'session-123'
        $result.PortalTenantId | Should -Be 'tenant-1234'
        $result.PortalUserId | Should -Be 'user@contoso.com'
        $result.SkipBootstrap | Should -BeTrue
        Assert-MockCalled Set-O365PortalSession -ModuleName O365Essentials -ParameterFilter {
            $Headers.AccessTokenGraph -eq 'graph-token' -and
            $RootAuthToken -eq 'root-cookie' -and
            $OIDCAuthCookie -eq 'oidc-cookie' -and
            $AjaxSessionKey -eq 'ajax-key' -and
            $SessionId -eq 'session-123' -and
            $TenantId -eq 'tenant-1234' -and
            $Username -eq 'user@contoso.com' -and
            $SkipBootstrap
        } -Exactly 1
    }

    It 'auto-attaches portal cookie state from process environment variables' {
        $cred = New-Object System.Management.Automation.PSCredential('user',(ConvertTo-SecureString 'pass' -AsPlainText -Force))
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROOT_AUTH_TOKEN', 'root-env', 'Process')
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_OIDC_AUTH_COOKIE', 'oidc-env', 'Process')
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_AJAX_SESSION_KEY', 'ajax-env', 'Process')
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_SESSION_ID', 'session-env', 'Process')
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_TENANT_ID', 'tenant-env', 'Process')
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROUTE_KEY', 'route-env', 'Process')
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_USERNAME', 'user@contoso.com', 'Process')
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_SKIP_BOOTSTRAP', 'true', 'Process')

        Mock -ModuleName O365Essentials ConvertFrom-JSONWebToken -MockWith {
            [pscustomobject]@{
                tid = 'tenant-id'
                upn = 'user@contoso.com'
            }
        }
        Mock -ModuleName O365Essentials Get-O365OAuthToken -MockWith {
            param($Tenant,$Scope,$Resource,$ClientId,$Credential,$RefreshToken,$Device,$ClientSecret,$Certificate,$CertificatePassword)
            if ($Scope -eq 'https://graph.microsoft.com/.default offline_access') {
                return [pscustomobject]@{
                    access_token  = 'graph-token'
                    refresh_token = 'refresh-token'
                    id_token      = 'header.payload.signature'
                }
            }
            if ($Scope -eq 'https://admin.microsoft.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'admin-token' }
            }
            if ($Scope -eq 'https://api.spaces.skype.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'teams-token' }
            }
            if ($Resource -eq '74658136-14ec-4630-ad9b-26e160ff0fc6') {
                return [pscustomobject]@{ access_token = 'portal-token' }
            }
            if ($Scope -eq 'https://management.azure.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'arm-token' }
            }
            if ($Resource -eq 'https://substrate.office.com') {
                return [pscustomobject]@{ access_token = 'substrate-token' }
            }
        }
        Mock -ModuleName O365Essentials Set-O365PortalSession -MockWith {
            param($Headers, $RootAuthToken, $OIDCAuthCookie, $AjaxSessionKey, $SessionId, $TenantId, $PortalRouteKey, $Username, $SkipBootstrap)
            [ordered] @{
                AccessTokenGraph = $Headers.AccessTokenGraph
                RootAuthToken    = $RootAuthToken
                OIDCAuthCookie   = $OIDCAuthCookie
                AjaxSessionKey   = $AjaxSessionKey
                SessionId        = $SessionId
                TenantId         = $TenantId
                PortalRouteKey   = $PortalRouteKey
                Username         = $Username
                SkipBootstrap    = [bool] $SkipBootstrap
            }
        }

        $result = Connect-O365Admin -Credential $cred

        $result.AccessTokenGraph | Should -Be 'graph-token'
        $result.RootAuthToken | Should -Be 'root-env'
        $result.OIDCAuthCookie | Should -Be 'oidc-env'
        $result.AjaxSessionKey | Should -Be 'ajax-env'
        $result.SessionId | Should -Be 'session-env'
        $result.TenantId | Should -Be 'tenant-env'
        $result.PortalRouteKey | Should -Be 'route-env'
        $result.Username | Should -Be 'user@contoso.com'
        $result.SkipBootstrap | Should -BeTrue
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROOT_AUTH_TOKEN', 'Process') | Should -BeNullOrEmpty
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_OIDC_AUTH_COOKIE', 'Process') | Should -BeNullOrEmpty
        Assert-MockCalled Set-O365PortalSession -ModuleName O365Essentials -ParameterFilter {
            $RootAuthToken -eq 'root-env' -and
            $OIDCAuthCookie -eq 'oidc-env' -and
            $AjaxSessionKey -eq 'ajax-env' -and
            $SessionId -eq 'session-env' -and
            $TenantId -eq 'tenant-env' -and
            $PortalRouteKey -eq 'route-env' -and
            $Username -eq 'user@contoso.com' -and
            $SkipBootstrap
        } -Exactly 1
    }

    It 'passes expanded portal cookie map from cookie list environment input' {
        $cred = New-Object System.Management.Automation.PSCredential('user',(ConvertTo-SecureString 'pass' -AsPlainText -Force))
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_COOKIE_LIST_JSON', '[{"name":"RootAuthToken","value":"root-list-env"},{"name":"OIDCAuthCookie","value":"oidc-list-env"},{"name":"s.DmnRQT","value":"domain-refresh-token"},{"name":"x-portal-routekey","value":"route-env"}]', 'Process')
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_SKIP_BOOTSTRAP', 'true', 'Process')

        Mock -ModuleName O365Essentials ConvertFrom-JSONWebToken -MockWith {
            [pscustomobject]@{
                tid = 'tenant-id'
                upn = 'user@contoso.com'
            }
        }
        Mock -ModuleName O365Essentials Get-O365OAuthToken -MockWith {
            param($Tenant,$Scope,$Resource,$ClientId,$Credential,$RefreshToken,$Device,$ClientSecret,$Certificate,$CertificatePassword)
            if ($Scope -eq 'https://graph.microsoft.com/.default offline_access') {
                return [pscustomobject]@{
                    access_token  = 'graph-token'
                    refresh_token = 'refresh-token'
                    id_token      = 'header.payload.signature'
                }
            }
            if ($Scope -eq 'https://admin.microsoft.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'admin-token' }
            }
            if ($Scope -eq 'https://api.spaces.skype.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'teams-token' }
            }
            if ($Resource -eq '74658136-14ec-4630-ad9b-26e160ff0fc6') {
                return [pscustomobject]@{ access_token = 'portal-token' }
            }
            if ($Scope -eq 'https://management.azure.com/.default offline_access') {
                return [pscustomobject]@{ access_token = 'arm-token' }
            }
            if ($Resource -eq 'https://substrate.office.com') {
                return [pscustomobject]@{ access_token = 'substrate-token' }
            }
        }
        Mock -ModuleName O365Essentials Set-O365PortalSession -MockWith {
            param($Headers, $RootAuthToken, $OIDCAuthCookie, $AdditionalCookies, $PortalRouteKey, $SkipBootstrap)
            [ordered] @{
                AccessTokenGraph = $Headers.AccessTokenGraph
                RootAuthToken    = $RootAuthToken
                OIDCAuthCookie   = $OIDCAuthCookie
                AdditionalCookieNames = @($AdditionalCookies.Keys)
                AdditionalCookieDomainRefreshToken = $AdditionalCookies['s.DmnRQT']
                PortalRouteKey   = $PortalRouteKey
                SkipBootstrap    = [bool] $SkipBootstrap
            }
        }

        $result = Connect-O365Admin -Credential $cred

        $result.AccessTokenGraph | Should -Be 'graph-token'
        $result.RootAuthToken | Should -Be 'root-list-env'
        $result.OIDCAuthCookie | Should -Be 'oidc-list-env'
        $result.AdditionalCookieNames | Should -Contain 's.DmnRQT'
        $result.AdditionalCookieDomainRefreshToken | Should -Be 'domain-refresh-token'
        $result.PortalRouteKey | Should -Be 'route-env'
        $result.SkipBootstrap | Should -BeTrue
        Assert-MockCalled Set-O365PortalSession -ModuleName O365Essentials -ParameterFilter {
            $RootAuthToken -eq 'root-list-env' -and
            $OIDCAuthCookie -eq 'oidc-list-env' -and
            $AdditionalCookies['s.DmnRQT'] -eq 'domain-refresh-token' -and
            $PortalRouteKey -eq 'route-env' -and
            $SkipBootstrap
        } -Exactly 1
    }
}
