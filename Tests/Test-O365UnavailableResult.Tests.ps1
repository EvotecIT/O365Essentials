Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Test-O365UnavailableResult' {
    BeforeAll {
        . "$PSScriptRoot/../Private/New-O365UnavailableResult.ps1"
    }

    It 'returns true for unavailable placeholder objects' {
        $Result = New-O365UnavailableResult -Name 'PurviewSettings' -Description 'Unavailable in this tenant.'

        Test-O365UnavailableResult -InputObject $Result | Should -BeTrue
    }

    It 'returns false for regular objects' {
        $Result = [pscustomobject] @{ Name = 'Regular'; DataBacked = $true }

        Test-O365UnavailableResult -InputObject $Result | Should -BeFalse
    }

    It 'returns false for null input' {
        Test-O365UnavailableResult -InputObject $null | Should -BeFalse
    }
}
