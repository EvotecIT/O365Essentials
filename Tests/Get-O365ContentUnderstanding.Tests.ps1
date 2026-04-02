Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365ContentUnderstanding' {
    It 'uses the primary setting endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365ContentUnderstanding -Name Setting

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.microsoft.com/admin/api/contentunderstanding/setting'
        } -Exactly 1
    }

    It 'builds the All bundle' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365ContentUnderstanding -Name All

        $Result.BillingSettings.Uri | Should -Be 'https://admin.microsoft.com/admin/api/contentunderstanding/billingSettings'
        $Result.PowerAppsEnvironments.Uri | Should -Be 'https://admin.microsoft.com/admin/api/contentunderstanding/powerAppsEnvironments'
    }

    It 'returns a placeholder when content understanding data is unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365ContentUnderstanding -Name Setting

        $Result.Name | Should -Be 'Setting'
        $Result.DataBacked | Should -BeFalse
    }
}
