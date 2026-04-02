Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365PayAsYouGoService' {
    It 'uses the data location and commitments endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/'; 'x-adminapp-request' = '/orgsettings/payasyougo' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365PayAsYouGoService -Name DataLocationAndCommitments

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/admin/api/tenant/datalocationandcommitments'
        } -Exactly 1
    }

    It 'returns captured write-only telemetry metadata' {
        $Result = Get-O365PayAsYouGoService -Name Telemetry

        $Result.Name | Should -Be 'Telemetry'
        $Result.RequestMethod | Should -Be 'POST'
        $Result.WriteOnly | Should -BeTrue
        $Result.SupportsDirectRead | Should -BeFalse
        $Result.EndpointObserved | Should -BeTrue
        $Result.ObservedTemplates.Count | Should -BeGreaterThan 0
    }

    It 'builds the All bundle from backup and content understanding surfaces' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/'; 'x-adminapp-request' = '/orgsettings/payasyougo' } }
        Mock -ModuleName O365Essentials Get-O365OrgBackup -MockWith { [pscustomobject] @{ Name = $Name; Source = 'Backup' } }
        Mock -ModuleName O365Essentials Get-O365ContentUnderstanding -MockWith { [pscustomobject] @{ Name = $Name; Source = 'ContentUnderstanding' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Name = 'DataLocationAndCommitments'; Source = 'Portal' } }

        $Result = Get-O365PayAsYouGoService -Name All

        $Result.BillingFeature.Source | Should -Be 'Backup'
        $Result.PrimarySetting.Source | Should -Be 'ContentUnderstanding'
        $Result.DataLocationAndCommitments.Source | Should -Be 'Portal'
        $Result.Telemetry.Name | Should -Be 'Telemetry'
    }

    It 'returns a placeholder when data location and commitments are unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/'; 'x-adminapp-request' = '/orgsettings/payasyougo' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365PayAsYouGoService -Name DataLocationAndCommitments

        $Result.Name | Should -Be 'DataLocationAndCommitments'
        $Result.DataBacked | Should -BeFalse
    }
}
