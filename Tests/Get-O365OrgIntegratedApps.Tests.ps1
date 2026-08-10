Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365OrgIntegratedApps' {
    It 'uses the app catalog endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }
        Get-O365OrgIntegratedApps -Name AppCatalog
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.microsoft.com/fd/addins/api/apps?workloads=AzureActiveDirectory,WXPO,MetaOS,SharePoint'
        } -Times 1 -Exactly
    }

    It 'returns a placeholder when integrated app data is unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365OrgIntegratedApps -Name AppCatalog

        $Result.Name | Should -Be 'AppCatalog'
        $Result.DataBacked | Should -BeFalse
    }
}
