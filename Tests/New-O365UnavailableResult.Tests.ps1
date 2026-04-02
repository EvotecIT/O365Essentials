Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'New-O365UnavailableResult' {
    BeforeAll {
        . "$PSScriptRoot/../Private/New-O365UnavailableResult.ps1"
    }

    It 'creates a consistent unavailable placeholder object' {
        $Result = New-O365UnavailableResult -Name 'PurviewSettings' -Description 'Unavailable in this tenant.'

        $Result.Name | Should -Be 'PurviewSettings'
        $Result.Description | Should -Be 'Unavailable in this tenant.'
        $Result.Reason | Should -Be 'TenantSpecific'
        $Result.DataBacked | Should -BeFalse
        $Result.IsUnavailable | Should -BeTrue
        $Result.IsOptional | Should -BeFalse
        $Result.PSObject.TypeNames | Should -Contain 'O365Essentials.UnavailableResult'
    }
}
