Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365OrgPeopleSettings' {
    It 'uses tenant-aware people endpoints' {
        $Headers = [ordered] @{ Tenant = 'contoso.onmicrosoft.com' }
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }
        Get-O365OrgPeopleSettings -Headers $Headers -Name Pronouns
        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.microsoft.com/fd/peopleadminservice/contoso.onmicrosoft.com/settings/pronouns'
        } -Exactly 1
    }

    It 'returns a placeholder when tenant information is missing' {
        $Headers = [ordered] @{}
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        InModuleScope O365Essentials {
            $Script:AuthorizationO365Cache = $null
        }

        $Result = Get-O365OrgPeopleSettings -Headers $Headers -Name Pronouns

        $Result.Name | Should -Be 'Pronouns'
        $Result.Reason | Should -Be 'MissingTenantId'
        $Result.DataBacked | Should -BeFalse
    }
}
