Import-Module $PSScriptRoot\..\O365Essentials.psd1 -Force

Describe 'Get-O365PortalAttachmentContext' {
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
                'O365ESSENTIALS_PORTAL_CLEAR_AFTER_READ',
                'O365ESSENTIALS_PORTAL_CONTEXT_JSON',
                'O365ESSENTIALS_PORTAL_COOKIE_HEADER',
                'O365ESSENTIALS_PORTAL_COOKIE_LIST_JSON'
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
                'O365ESSENTIALS_PORTAL_CLEAR_AFTER_READ',
                'O365ESSENTIALS_PORTAL_CONTEXT_JSON',
                'O365ESSENTIALS_PORTAL_COOKIE_HEADER',
                'O365ESSENTIALS_PORTAL_COOKIE_LIST_JSON'
            )) {
            [Environment]::SetEnvironmentVariable($EnvironmentName, $null, 'Process')
        }
    }

    It 'reads compact portal context from json environment input' {
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_CONTEXT_JSON', '{"rootAuthToken":"root-json-env","oidcAuthCookie":"oidc-json-env","ajaxSessionKey":"ajax-json-env","tenantId":"tenant-json-env","username":"json-env@contoso.com"}', 'Process')

        InModuleScope O365Essentials {
            $result = Get-O365PortalAttachmentContext
            $result.RootAuthToken | Should -Be 'root-json-env'
            $result.OIDCAuthCookie | Should -Be 'oidc-json-env'
            $result.AjaxSessionKey | Should -Be 'ajax-json-env'
            $result.TenantId | Should -Be 'tenant-json-env'
            $result.Username | Should -Be 'json-env@contoso.com'
        }
    }

    It 'reads compact portal context from cookie header environment input' {
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_COOKIE_HEADER', 'RootAuthToken=root-header-env; SPAAuthCookie=spa-header-env; s.AjaxSessionKey=ajax-header-env; s.UserTenantId=tenant-header-env; s.userid=header-env@contoso.com', 'Process')

        InModuleScope O365Essentials {
            $result = Get-O365PortalAttachmentContext
            $result.RootAuthToken | Should -Be 'root-header-env'
            $result.SPAAuthCookie | Should -Be 'spa-header-env'
            $result.AjaxSessionKey | Should -Be 'ajax-header-env'
            $result.TenantId | Should -Be 'tenant-header-env'
            $result.Username | Should -Be 'header-env@contoso.com'
        }
    }

    It 'reads compact portal context from cookie list environment input' {
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_COOKIE_LIST_JSON', '[{"name":"RootAuthToken","value":"root-list-env"},{"name":"OIDCAuthCookie","value":"oidc-list-env"},{"name":"s.AjaxSessionKey","value":"ajax-list-env"},{"name":"s.UserTenantId","value":"tenant-list-env"},{"name":"s.userid","value":"list-env@contoso.com"}]', 'Process')

        InModuleScope O365Essentials {
            $result = Get-O365PortalAttachmentContext
            $result.RootAuthToken | Should -Be 'root-list-env'
            $result.OIDCAuthCookie | Should -Be 'oidc-list-env'
            $result.AjaxSessionKey | Should -Be 'ajax-list-env'
            $result.TenantId | Should -Be 'tenant-list-env'
            $result.Username | Should -Be 'list-env@contoso.com'
        }
    }

    It 'preserves the expanded cookie map from cookie list environment input' {
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_COOKIE_LIST_JSON', '[{"name":"RootAuthToken","value":"root-list-env"},{"name":"OIDCAuthCookie","value":"oidc-list-env"},{"name":"s.DmnRQT","value":"domain-refresh-token"},{"name":"x-portal-routekey","value":"weu"}]', 'Process')

        InModuleScope O365Essentials {
            $result = Get-O365PortalAttachmentContext
            $result.CookieMap['RootAuthToken'] | Should -Be 'root-list-env'
            $result.CookieMap['s.DmnRQT'] | Should -Be 'domain-refresh-token'
            $result.CookieMap['x-portal-routekey'] | Should -Be 'weu'
        }
    }

    It 'clears compact portal env values after reading by default' {
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_COOKIE_HEADER', 'RootAuthToken=root-header-env; OIDCAuthCookie=oidc-header-env', 'Process')

        InModuleScope O365Essentials {
            $null = Get-O365PortalAttachmentContext
        }

        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_COOKIE_HEADER', 'Process') | Should -BeNullOrEmpty
    }

    It 'returns null for invalid compact portal json input' {
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_CONTEXT_JSON', '{"broken":', 'Process')

        InModuleScope O365Essentials {
            Get-O365PortalAttachmentContext | Should -BeNullOrEmpty
        }
    }
}
