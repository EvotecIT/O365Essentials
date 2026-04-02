Import-Module $PSScriptRoot\..\O365Essentials.psd1 -Force

Describe 'Clear-O365PortalAttachmentContext' {
    BeforeEach {
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROOT_AUTH_TOKEN', 'root-cookie', 'Process')
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_OIDC_AUTH_COOKIE', 'oidc-cookie', 'Process')
        [Environment]::SetEnvironmentVariable('O365ESSENTIALS_PORTAL_CLEAR_AFTER_READ', 'false', 'Process')
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

    It 'removes process-scoped portal attachment values' {
        $result = InModuleScope O365Essentials {
            Clear-O365PortalAttachmentContext
        }

        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_ROOT_AUTH_TOKEN', 'Process') | Should -BeNullOrEmpty
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_OIDC_AUTH_COOKIE', 'Process') | Should -BeNullOrEmpty
        [Environment]::GetEnvironmentVariable('O365ESSENTIALS_PORTAL_CLEAR_AFTER_READ', 'Process') | Should -BeNullOrEmpty
        $result.Cleared | Should -BeTrue
        $result.RemovedCount | Should -Be 3
    }
}
