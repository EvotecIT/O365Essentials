BeforeAll {
    . "$PSScriptRoot/../Private/Get-O365OAuthToken.ps1"
}

Describe 'OAuth client identity' {
    BeforeEach {
        $script:TokenRequest = $null
        Mock Invoke-RestMethod {
            param($Method, $Uri, $Body, $ContentType)
            $script:TokenRequest = $Body
            [pscustomobject] @{ access_token = 'test-access-token' }
        }
    }

    It 'uses the admin-compatible public client for delegated token refresh' {
        $null = Get-O365OAuthToken -Tenant 'contoso.onmicrosoft.com' -Scope 'https://admin.microsoft.com/.default offline_access' -RefreshToken 'test-refresh-token'

        $script:TokenRequest.client_id | Should -Be '1950a258-227b-4e31-a9cf-717495945fc2'
    }

    It 'preserves the caller app identity for client credentials' {
        $null = Get-O365OAuthToken -Tenant 'contoso.onmicrosoft.com' -Scope 'https://admin.microsoft.com/.default' -ClientId 'd75eba19-9b64-4405-9b22-649195df137c' -ClientSecret 'test-client-secret'

        $script:TokenRequest.client_id | Should -Be 'd75eba19-9b64-4405-9b22-649195df137c'
        $script:TokenRequest.grant_type | Should -Be 'client_credentials'
    }
}
