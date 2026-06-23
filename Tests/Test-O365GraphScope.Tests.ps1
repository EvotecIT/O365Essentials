Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Test-O365GraphScope' {
    It 'returns true when all required scopes are granted' {
        InModuleScope O365Essentials {
            Test-O365GraphScope -GrantedScope 'User.Read Policy.Read.All' -RequiredScope 'Policy.Read.All' | Should -BeTrue
        }
    }

    It 'returns false when a required scope is missing' {
        InModuleScope O365Essentials {
            Test-O365GraphScope -GrantedScope 'User.Read' -RequiredScope 'Policy.Read.All' | Should -BeFalse
        }
    }

    It 'ignores auxiliary OAuth scopes' {
        InModuleScope O365Essentials {
            Test-O365GraphScope -GrantedScope 'Policy.Read.All' -RequiredScope 'openid profile offline_access Policy.Read.All' | Should -BeTrue
        }
    }
}
