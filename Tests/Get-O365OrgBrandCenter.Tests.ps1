Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365OrgBrandCenter' {
    It 'uses the configuration endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365OrgBrandCenter -Name Configuration

        $Result.Uri | Should -Be 'https://admin.microsoft.com/_api/spo.tenant/GetBrandCenterConfiguration'
    }

    It 'returns grouped data for All' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365OrgBrandCenter

        $Result.Configuration.Uri | Should -Be 'https://admin.microsoft.com/_api/spo.tenant/GetBrandCenterConfiguration'
        $Result.SiteUrl.Uri | Should -Be "https://admin.microsoft.com/_api/GroupSiteManager/GetValidSiteUrlFromAlias?alias='BrandGuide'&managedPath='sites'"
    }

    It 'returns a placeholder when site url data is unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.microsoft.com/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365OrgBrandCenter -Name SiteUrl

        $Result.Name | Should -Be 'SiteUrl'
        $Result.DataBacked | Should -BeFalse
    }
}
