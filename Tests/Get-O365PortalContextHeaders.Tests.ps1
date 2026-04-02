Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365PortalContextHeaders' {
    BeforeAll {
        . "$PSScriptRoot/../Private/Get-O365PortalContextHeaders.ps1"
    }

    It 'builds People context headers' {
        $Headers = Get-O365PortalContextHeaders -Context People
        $Headers['x-adminapp-request'] | Should -Be '/Settings/OrgSettings/People'
        $Headers['Referer'] | Should -Be 'https://admin.microsoft.com/'
    }

    It 'adds AjaxSessionKey when provided' {
        $Headers = Get-O365PortalContextHeaders -Context Agents -AjaxSessionKey 'abc123'
        $Headers['AjaxSessionKey'] | Should -Be 'abc123'
    }

    It 'adds portal route key when provided' {
        $Headers = Get-O365PortalContextHeaders -Context MicrosoftSearch -PortalRouteKey 'weu'
        $Headers['x-portal-routekey'] | Should -Be 'weu'
    }

    It 'builds MicrosoftSearch context headers using live portal defaults' {
        $Headers = Get-O365PortalContextHeaders -Context MicrosoftSearch -PortalHost 'https://admin.cloud.microsoft'
        $Headers['Referer'] | Should -Be 'https://admin.cloud.microsoft/'
        $Headers['x-adminapp-request'] | Should -Be '/MicrosoftSearch'
        $Headers['x-ms-mac-appid'] | Should -Be '8788975c-133f-4d33-acb5-3fb1ba00e746'
        $Headers['x-ms-mac-version'] | Should -Be 'host-mac_2026.3.26.4'
    }

    It 'builds Backup context headers' {
        $Headers = Get-O365PortalContextHeaders -Context Backup
        $Headers['x-adminapp-request'] | Should -Be '/Settings/enhancedRestore'
        $Headers['Referer'] | Should -Be 'https://admin.microsoft.com/'
    }

    It 'builds PayAsYouGo context headers' {
        $Headers = Get-O365PortalContextHeaders -Context PayAsYouGo
        $Headers['x-adminapp-request'] | Should -Be '/orgsettings/payasyougo'
        $Headers['Referer'] | Should -Be 'https://admin.microsoft.com/'
    }

    It 'builds MicrosoftEdge context headers' {
        $Headers = Get-O365PortalContextHeaders -Context MicrosoftEdge
        $Headers['Referer'] | Should -Be 'https://admin.microsoft.com/'
    }

    It 'builds BrandCenter context headers' {
        $Headers = Get-O365PortalContextHeaders -Context BrandCenter
        $Headers['Referer'] | Should -Be 'https://admin.microsoft.com/'
    }
}
