Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Set-O365PortalSession' {
    It 'attaches bootstrap-derived portal session metadata to the current connection' {
        $baseHeaders = [ordered] @{
            ExpiresOnUTC = (Get-Date).AddMinutes(10)
            UserName     = 'user@contoso.com'
            HeadersO365  = @{ Authorization = 'Bearer o365' }
        }
        $webSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()

        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        Mock -ModuleName O365Essentials Initialize-O365PortalWebSession -MockWith {
            [pscustomobject] @{
                WebSession     = $webSession
                AjaxSessionKey = 'ajax-key'
                PortalRouteKey = 'weu'
                TenantId       = 'tenant-1234'
                UserId         = 'user@contoso.com'
            }
        }

        $result = InModuleScope O365Essentials {
            param($baseHeaders, $webSession)
            Set-O365PortalSession -Headers $baseHeaders -WebSession $webSession
        } -Parameters @{ baseHeaders = $baseHeaders; webSession = $webSession }

        $result.PortalWebSession | Should -Be $webSession
        $result.AjaxSessionKey | Should -Be 'ajax-key'
        $result.PortalRouteKey | Should -Be 'weu'
        $result.HeadersPortal.AjaxSessionKey | Should -Be 'ajax-key'
        $result.HeadersPortal['x-portal-routekey'] | Should -Be 'weu'
    }

    It 'accepts cookie mode when SPA auth cookie is absent' {
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { [ordered] @{} }

        $result = InModuleScope O365Essentials {
            Set-O365PortalSession -RootAuthToken 'root-cookie' -OIDCAuthCookie 'oidc-cookie' -AjaxSessionKey 'ajax-key' -SessionId 'session-123' -TenantId 'tenant-1234' -Username 'user@contoso.com' -SkipBootstrap
        }

        $portalCookies = $result.PortalWebSession.Cookies.GetCookies('https://admin.cloud.microsoft/')

        ($portalCookies | Where-Object Name -eq 'RootAuthToken').Count | Should -Be 1
        ($portalCookies | Where-Object Name -eq 'OIDCAuthCookie').Count | Should -Be 1
        ($portalCookies | Where-Object Name -eq 'SPAAuthCookie').Count | Should -Be 0
        $result.AjaxSessionKey | Should -Be 'ajax-key'
        $result.PortalTenantId | Should -Be 'tenant-1234'
        $result.PortalUserId | Should -Be 'user@contoso.com'
    }

    It 'preserves additional admin portal cookies in cookie mode' {
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { [ordered] @{} }

        $result = InModuleScope O365Essentials {
            Set-O365PortalSession -RootAuthToken 'root-cookie' -OIDCAuthCookie 'oidc-cookie' -AdditionalCookies ([ordered] @{ 's.DmnRQT' = 'domain-refresh-token'; 's.cachemap' = 'cache-map' }) -SkipBootstrap
        }

        $portalCookies = $result.PortalWebSession.Cookies.GetCookies('https://admin.cloud.microsoft/')

        ($portalCookies | Where-Object Name -eq 's.DmnRQT' | Select-Object -First 1).Value | Should -Be 'domain-refresh-token'
        ($portalCookies | Where-Object Name -eq 's.cachemap' | Select-Object -First 1).Value | Should -Be 'cache-map'
    }

    It 'decodes portal session values for replay headers while keeping cookie values intact' {
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { [ordered] @{} }

        $result = InModuleScope O365Essentials {
            Set-O365PortalSession -RootAuthToken 'root-cookie' -OIDCAuthCookie 'oidc-cookie' -AjaxSessionKey 'abc%2Fdef%2Bghi%3D%3D' -PortalRouteKey 'frc-uas' -SkipBootstrap
        }

        $portalCookies = $result.PortalWebSession.Cookies.GetCookies('https://admin.cloud.microsoft/')

        ($portalCookies | Where-Object Name -eq 's.AjaxSessionKey' | Select-Object -First 1).Value | Should -Be 'abc%2Fdef%2Bghi%3D%3D'
        $result.AjaxSessionKey | Should -Be 'abc/def+ghi=='
        $result.HeadersPortal.AjaxSessionKey | Should -Be 'abc/def+ghi=='
        $result.HeadersPortal['x-ms-mac-appid'] | Should -Be '8788975c-133f-4d33-acb5-3fb1ba00e746'
    }
}
