Import-Module $PSScriptRoot\..\O365Essentials.psd1 -Force

Describe 'Set-O365PortalAttachmentContext' {
    BeforeEach {
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

    It 'stores process-scoped portal attachment values for Connect-O365Admin' {
        $result = InModuleScope O365Essentials {
            Set-O365PortalAttachmentContext -RootAuthToken 'root-cookie' -OIDCAuthCookie 'oidc-cookie' -AjaxSessionKey 'ajax-key' -TenantId 'tenant-1234' -Username 'user@contoso.com' -SkipBootstrap
        }

        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROOT_AUTH_TOKEN', 'Process') | Should -Be 'root-cookie'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_OIDC_AUTH_COOKIE', 'Process') | Should -Be 'oidc-cookie'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_AJAX_SESSION_KEY', 'Process') | Should -Be 'ajax-key'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_TENANT_ID', 'Process') | Should -Be 'tenant-1234'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_USERNAME', 'Process') | Should -Be 'user@contoso.com'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_SKIP_BOOTSTRAP', 'Process') | Should -Be 'true'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_CLEAR_AFTER_READ', 'Process') | Should -Be 'true'
        $result.RootAuthTokenPresent | Should -BeTrue
        $result.OIDCAuthCookiePresent | Should -BeTrue
        $result.ClearAfterRead | Should -BeTrue
    }

    It 'allows keeping seeded portal values after Connect-O365Admin reads them' {
        InModuleScope O365Essentials {
            Set-O365PortalAttachmentContext -RootAuthToken 'root-cookie' -SPAAuthCookie 'spa-cookie' -ClearAfterRead $false | Out-Null
        }

        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_SPA_AUTH_COOKIE', 'Process') | Should -Be 'spa-cookie'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_CLEAR_AFTER_READ', 'Process') | Should -Be 'false'
    }

    It 'extracts portal attachment values from a WebRequestSession' {
        $session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
        foreach ($Cookie in @(
                [System.Net.Cookie]::new('RootAuthToken', 'root-from-session', '/', 'admin.cloud.microsoft'),
                [System.Net.Cookie]::new('OIDCAuthCookie', 'oidc-from-session', '/', 'admin.cloud.microsoft'),
                [System.Net.Cookie]::new('s.AjaxSessionKey', 'ajax-from-session', '/', 'admin.cloud.microsoft'),
                [System.Net.Cookie]::new('s.SessID', 'session-from-session', '/', 'admin.cloud.microsoft'),
                [System.Net.Cookie]::new('s.UserTenantId', 'tenant-from-session', '/', 'admin.cloud.microsoft'),
                [System.Net.Cookie]::new('x-portal-routekey', 'route-from-session', '/', 'admin.cloud.microsoft'),
                [System.Net.Cookie]::new('s.userid', 'user@contoso.com', '/', 'admin.cloud.microsoft')
            )) {
            $session.Cookies.Add($Cookie)
        }

        $result = InModuleScope O365Essentials {
            param($session)
            Set-O365PortalAttachmentContext -WebSession $session
        } -Parameters @{ session = $session }

        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROOT_AUTH_TOKEN', 'Process') | Should -Be 'root-from-session'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_OIDC_AUTH_COOKIE', 'Process') | Should -Be 'oidc-from-session'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_AJAX_SESSION_KEY', 'Process') | Should -Be 'ajax-from-session'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_SESSION_ID', 'Process') | Should -Be 'session-from-session'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_TENANT_ID', 'Process') | Should -Be 'tenant-from-session'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROUTE_KEY', 'Process') | Should -Be 'route-from-session'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_USERNAME', 'Process') | Should -Be 'user@contoso.com'
        $result.RootAuthTokenPresent | Should -BeTrue
        $result.OIDCAuthCookiePresent | Should -BeTrue
        $result.PortalRouteKeyPresent | Should -BeTrue
    }

    It 'extracts portal attachment values from a cookie map' {
        $result = InModuleScope O365Essentials {
            Set-O365PortalAttachmentContext -CookieMap ([ordered] @{
                    RootAuthToken = 'root-from-map'
                    OIDCAuthCookie = 'oidc-from-map'
                    's.AjaxSessionKey' = 'ajax-from-map'
                    's.SessID' = 'session-from-map'
                    's.UserTenantId' = 'tenant-from-map'
                    'x-portal-routekey' = 'route-from-map'
                    's.userid' = 'map-user@contoso.com'
                })
        }

        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROOT_AUTH_TOKEN', 'Process') | Should -Be 'root-from-map'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_OIDC_AUTH_COOKIE', 'Process') | Should -Be 'oidc-from-map'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_AJAX_SESSION_KEY', 'Process') | Should -Be 'ajax-from-map'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_SESSION_ID', 'Process') | Should -Be 'session-from-map'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_TENANT_ID', 'Process') | Should -Be 'tenant-from-map'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROUTE_KEY', 'Process') | Should -Be 'route-from-map'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_USERNAME', 'Process') | Should -Be 'map-user@contoso.com'
        $result.RootAuthTokenPresent | Should -BeTrue
        $result.OIDCAuthCookiePresent | Should -BeTrue
    }

    It 'extracts portal attachment values from json input' {
        $json = '{"rootAuthToken":"root-from-json","spaAuthCookie":"spa-from-json","ajaxSessionKey":"ajax-from-json","tenantId":"tenant-from-json","portalRouteKey":"route-from-json","username":"json-user@contoso.com"}'

        $result = InModuleScope O365Essentials {
            param($json)
            Set-O365PortalAttachmentContext -Json $json
        } -Parameters @{ json = $json }

        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROOT_AUTH_TOKEN', 'Process') | Should -Be 'root-from-json'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_SPA_AUTH_COOKIE', 'Process') | Should -Be 'spa-from-json'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_AJAX_SESSION_KEY', 'Process') | Should -Be 'ajax-from-json'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_TENANT_ID', 'Process') | Should -Be 'tenant-from-json'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROUTE_KEY', 'Process') | Should -Be 'route-from-json'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_USERNAME', 'Process') | Should -Be 'json-user@contoso.com'
        $result.RootAuthTokenPresent | Should -BeTrue
        $result.SPAAuthCookiePresent | Should -BeTrue
    }

    It 'extracts portal attachment values from a raw cookie header' {
        $cookieHeader = 'RootAuthToken=root-from-header; OIDCAuthCookie=oidc-from-header; s.AjaxSessionKey=ajax-from-header; s.SessID=session-from-header; s.UserTenantId=tenant-from-header; x-portal-routekey=route-from-header; s.userid=header-user@contoso.com'

        $result = InModuleScope O365Essentials {
            param($cookieHeader)
            Set-O365PortalAttachmentContext -CookieHeader $cookieHeader
        } -Parameters @{ cookieHeader = $cookieHeader }

        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROOT_AUTH_TOKEN', 'Process') | Should -Be 'root-from-header'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_OIDC_AUTH_COOKIE', 'Process') | Should -Be 'oidc-from-header'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_AJAX_SESSION_KEY', 'Process') | Should -Be 'ajax-from-header'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_SESSION_ID', 'Process') | Should -Be 'session-from-header'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_TENANT_ID', 'Process') | Should -Be 'tenant-from-header'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROUTE_KEY', 'Process') | Should -Be 'route-from-header'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_USERNAME', 'Process') | Should -Be 'header-user@contoso.com'
        $result.RootAuthTokenPresent | Should -BeTrue
        $result.OIDCAuthCookiePresent | Should -BeTrue
    }

    It 'extracts portal attachment values from a browser cookie list' {
        $cookieList = @(
            [PSCustomObject] @{ name = 'RootAuthToken'; value = 'root-from-list' },
            [PSCustomObject] @{ name = 'SPAAuthCookie'; value = 'spa-from-list' },
            [PSCustomObject] @{ name = 's.AjaxSessionKey'; value = 'ajax-from-list' },
            [PSCustomObject] @{ name = 's.SessID'; value = 'session-from-list' },
            [PSCustomObject] @{ name = 's.UserTenantId'; value = 'tenant-from-list' },
            [PSCustomObject] @{ name = 'x-portal-routekey'; value = 'route-from-list' },
            [PSCustomObject] @{ name = 's.userid'; value = 'list-user@contoso.com' }
        )

        $result = InModuleScope O365Essentials {
            param($cookieList)
            Set-O365PortalAttachmentContext -CookieList $cookieList
        } -Parameters @{ cookieList = $cookieList }

        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROOT_AUTH_TOKEN', 'Process') | Should -Be 'root-from-list'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_SPA_AUTH_COOKIE', 'Process') | Should -Be 'spa-from-list'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_AJAX_SESSION_KEY', 'Process') | Should -Be 'ajax-from-list'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_SESSION_ID', 'Process') | Should -Be 'session-from-list'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_TENANT_ID', 'Process') | Should -Be 'tenant-from-list'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROUTE_KEY', 'Process') | Should -Be 'route-from-list'
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_USERNAME', 'Process') | Should -Be 'list-user@contoso.com'
        $result.RootAuthTokenPresent | Should -BeTrue
        $result.SPAAuthCookiePresent | Should -BeTrue
    }

    It 'requires at least one portal auth cookie in addition to RootAuthToken' {
        InModuleScope O365Essentials {
            { Set-O365PortalAttachmentContext -RootAuthToken 'root-cookie' -ErrorAction Stop } | Should -Throw
        }
    }

    It 'rejects invalid json input' {
        InModuleScope O365Essentials {
            { Set-O365PortalAttachmentContext -Json '{"broken":' -ErrorAction Stop } | Should -Throw
        }
    }
}
