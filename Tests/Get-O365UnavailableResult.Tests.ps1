Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365UnavailableResult' {
    BeforeAll {
        . "$PSScriptRoot/../Private/New-O365UnavailableResult.ps1"
    }

    It 'returns a direct unavailable result at the root path' {
        $InputObject = New-O365UnavailableResult -Name 'RootItem' -Description 'Unavailable root.' -IsOptional $true

        $Result = Get-O365UnavailableResult -InputObject $InputObject

        $Result.Path | Should -Be '$'
        $Result.Name | Should -Be 'RootItem'
        $Result.IsOptional | Should -BeTrue
        (Test-O365UnavailableResult -InputObject $Result.Result) | Should -BeTrue
    }

    It 'finds unavailable results nested in custom objects' {
        $InputObject = [PSCustomObject] @{
            Security = [PSCustomObject] @{
                PurviewBootInfo = New-O365UnavailableResult -Name 'PurviewBootInfo' -Description 'Unavailable nested.'
                HealthyValue    = [PSCustomObject] @{ Name = 'Healthy' }
            }
        }

        $Result = Get-O365UnavailableResult -InputObject $InputObject

        $Result.Path | Should -Be '$.Security.PurviewBootInfo'
        $Result.Name | Should -Be 'PurviewBootInfo'
    }

    It 'finds unavailable results inside arrays' {
        $InputObject = [PSCustomObject] @{
            Items = @(
                [PSCustomObject] @{ Name = 'Healthy' }
                (New-O365UnavailableResult -Name 'Item2' -Description 'Unavailable array item.')
            )
        }

        $Result = Get-O365UnavailableResult -InputObject $InputObject

        $Result.Path | Should -Be '$.Items[1]'
        $Result.Name | Should -Be 'Item2'
    }

    It 'ignores null child properties while traversing nested objects' {
        $InputObject = [PSCustomObject] @{
            Healthy = $null
            Nested  = [PSCustomObject] @{
                Missing = $null
                Failed  = New-O365UnavailableResult -Name 'FailedItem' -Description 'Unavailable nested item.'
            }
        }

        { Get-O365UnavailableResult -InputObject $InputObject } | Should -Not -Throw
        $Result = Get-O365UnavailableResult -InputObject $InputObject

        $Result.Path | Should -Be '$.Nested.Failed'
        $Result.Name | Should -Be 'FailedItem'
    }

    It 'ignores internal O365 timing metadata properties' {
        $Placeholder = New-O365UnavailableResult -Name 'Recommendations' -Description 'Unavailable nested item.'
        $InputObject = [PSCustomObject] @{
            Recommendations       = $Placeholder
            __O365ComponentTimings = @{
                Recommendations = [pscustomobject] @{
                    Name  = 'Recommendations'
                    Value = $Placeholder
                }
            }
        }

        $Result = @(Get-O365UnavailableResult -InputObject $InputObject)

        $Result.Count | Should -Be 1
        $Result[0].Path | Should -Be '$.Recommendations'
    }
}
