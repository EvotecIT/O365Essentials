Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365UnavailableSummary' {
    BeforeAll {
        . "$PSScriptRoot/../Private/New-O365UnavailableResult.ps1"
    }

    It 'returns an empty summary for healthy objects' {
        $InputObject = [PSCustomObject] @{
            Name = 'Healthy'
            Data = [PSCustomObject] @{ Value = 1 }
        }

        $Result = Get-O365UnavailableSummary -InputObject $InputObject

        $Result.HasUnavailableItems | Should -BeFalse
        $Result.UnavailableCount | Should -Be 0
        $Result.Names.Count | Should -Be 0
    }

    It 'summarizes nested unavailable results' {
        $InputObject = [PSCustomObject] @{
            Security = [PSCustomObject] @{
                PurviewBootInfo = New-O365UnavailableResult -Name 'PurviewBootInfo' -Description 'Unavailable nested.'
                Policies        = New-O365UnavailableResult -Name 'DefaultDlpPolicy' -Description 'Unavailable nested.'
            }
        }

        $Result = Get-O365UnavailableSummary -InputObject $InputObject

        $Result.HasUnavailableItems | Should -BeTrue
        $Result.UnavailableCount | Should -Be 2
        $Result.Names | Should -Contain 'PurviewBootInfo'
        $Result.Names | Should -Contain 'DefaultDlpPolicy'
        $Result.Paths | Should -Contain '$.Security.PurviewBootInfo'
    }

    It 'returns an empty summary for null input' {
        $Result = Get-O365UnavailableSummary -InputObject $null

        $Result.HasUnavailableItems | Should -BeFalse
        $Result.UnavailableCount | Should -Be 0
        $Result.Items.Count | Should -Be 0
    }
}
