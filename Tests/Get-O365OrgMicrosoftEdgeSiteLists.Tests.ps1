Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365OrgMicrosoftEdgeSiteLists' {
    It 'uses the site lists endpoint' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365OrgMicrosoftEdgeSiteLists -Name SiteLists

        $Result.Uri | Should -Be 'https://admin.cloud.microsoft/fd/edgeenterprisesitemanagement/api/v2/emiesitelists'
    }

    It 'returns grouped data for All' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        $Result = Get-O365OrgMicrosoftEdgeSiteLists

        $Result.SiteLists.Uri | Should -Be 'https://admin.cloud.microsoft/fd/edgeenterprisesitemanagement/api/v2/emiesitelists'
        $Result.Notifications.Uri | Should -Be 'https://admin.cloud.microsoft/fd/edgeenterprisesitemanagement/api/v2/notifications'
    }

    It 'returns a placeholder when notifications data is unavailable' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { $null }

        $Result = Get-O365OrgMicrosoftEdgeSiteLists -Name Notifications

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/fd/edgeenterprisesitemanagement/api/v2/notifications' -and
            $QuietOnError
        } -Exactly 1
        $Result.Name | Should -Be 'Notifications'
        $Result.DataBacked | Should -BeFalse
        $Result.Description | Should -Match 'optional'
        $Result.IsOptional | Should -BeTrue
    }

    It 'prefers portal session replay when portal session metadata is available' {
        Mock -ModuleName O365Essentials Get-O365PortalContextHeaders -MockWith { @{ Referer = 'https://admin.cloud.microsoft/'; AjaxSessionKey = 'ajax-key'; 'x-portal-routekey' = 'weu' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { [pscustomobject] @{ Uri = $Uri } }

        Get-O365OrgMicrosoftEdgeSiteLists -Headers @{ AjaxSessionKey = 'ajax-key'; PortalRouteKey = 'weu'; PortalWebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new() } -Name SiteLists | Out-Null

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.cloud.microsoft/fd/edgeenterprisesitemanagement/api/v2/emiesitelists' -and
            $UsePortalSession -and
            $AdditionalHeaders.AjaxSessionKey -eq 'ajax-key' -and
            $AdditionalHeaders['x-portal-routekey'] -eq 'weu'
        } -Exactly 1
    }
}
