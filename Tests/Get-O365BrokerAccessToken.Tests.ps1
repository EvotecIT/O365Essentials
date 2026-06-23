Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

BeforeAll {
    if (-not ('O365Essentials.Auth.BrokerTokenClient' -as [type])) {
        Add-Type -TypeDefinition @'
using System;

namespace O365Essentials.Auth
{
    public sealed class BrokerTokenResult
    {
        public BrokerTokenResult()
        {
            AccessToken = string.Empty;
            Scopes = new string[0];
        }

        public string AccessToken { get; set; }
        public DateTimeOffset ExpiresOn { get; set; }
        public string TenantId { get; set; }
        public string AccountUsername { get; set; }
        public string[] Scopes { get; set; }
    }

    public static class BrokerTokenClient
    {
        public static string LastClientId { get; private set; }
        public static string LastCall { get; private set; }

        public static BrokerTokenResult AcquireTokenForResource(
            string tenant,
            string resourceUrl,
            string clientId,
            string accountUsername,
            bool forcePrompt)
        {
            LastCall = "Resource";
            LastClientId = clientId;
            return CreateResult(resourceUrl, accountUsername);
        }

        public static BrokerTokenResult AcquireTokenForScope(
            string tenant,
            string scope,
            string clientId,
            string accountUsername,
            bool forcePrompt)
        {
            LastCall = "Scope";
            LastClientId = clientId;
            return CreateResult(scope, accountUsername);
        }

        private static BrokerTokenResult CreateResult(string target, string accountUsername)
        {
            return new BrokerTokenResult
            {
                AccessToken = "token:" + target,
                ExpiresOn = DateTimeOffset.UtcNow.AddHours(1),
                TenantId = "tenant-id",
                AccountUsername = accountUsername,
                Scopes = new[] { target }
            };
        }
    }
}
'@
    }
}

Describe 'Get-O365BrokerAccessToken' -Skip:($PSEdition -ne 'Core' -or $PSVersionTable.PSVersion -lt [version] '7.4') {
    It 'uses the admin resource WAM client by default for resource requests' {
        InModuleScope O365Essentials {
            Get-O365BrokerAccessToken -ResourceUrl 'https://admin.microsoft.com/' -Account 'user@contoso.com' | Out-Null

            [O365Essentials.Auth.BrokerTokenClient]::LastCall | Should -Be 'Resource'
            [O365Essentials.Auth.BrokerTokenClient]::LastClientId | Should -Be '1950a258-227b-4e31-a9cf-717495945fc2'
        }
    }

    It 'uses the Microsoft Graph PowerShell WAM client by default for scope requests' {
        InModuleScope O365Essentials {
            Get-O365BrokerAccessToken -Scope 'Policy.Read.All' -Account 'user@contoso.com' | Out-Null

            [O365Essentials.Auth.BrokerTokenClient]::LastCall | Should -Be 'Scope'
            [O365Essentials.Auth.BrokerTokenClient]::LastClientId | Should -Be '14d82eec-204b-4c2f-b7e8-296a70dab67e'
        }
    }

    It 'lets callers override the WAM client id' {
        InModuleScope O365Essentials {
            Get-O365BrokerAccessToken -Scope 'Policy.Read.All' -ClientId 'custom-client' -Account 'user@contoso.com' | Out-Null

            [O365Essentials.Auth.BrokerTokenClient]::LastClientId | Should -Be 'custom-client'
        }
    }
}
