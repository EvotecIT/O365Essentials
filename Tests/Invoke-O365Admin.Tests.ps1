Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Invoke-O365Admin header selection' {
    It 'uses Azure portal headers for directory endpoints' {
        $headers = [ordered]@{
            HeadersO365  = @{ Authorization = 'Bearer o365' }
            HeadersGraph = @{ Authorization = 'Bearer graph' }
            HeadersAzure = @{ Authorization = 'Bearer portal' }
            HeadersARM   = @{ Authorization = 'Bearer arm' }
        }
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        Mock -ModuleName O365Essentials Invoke-RestMethod -MockWith { }
        Invoke-O365Admin -Uri 'https://main.iam.ad.ext.azure.com/api/test' -Headers $headers
        Assert-MockCalled Invoke-RestMethod -ModuleName O365Essentials -ParameterFilter { $Headers.Authorization -eq 'Bearer portal' } -Exactly 1
    }
    It 'falls back to ARM headers when portal token is missing' {
        $headers = [ordered]@{
            HeadersO365  = @{ Authorization = 'Bearer o365' }
            HeadersGraph = @{ Authorization = 'Bearer graph' }
            HeadersAzure = $null
            HeadersARM   = @{ Authorization = 'Bearer arm' }
        }
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        Mock -ModuleName O365Essentials Invoke-RestMethod -MockWith { }
        Invoke-O365Admin -Uri 'https://main.iam.ad.ext.azure.com/api/test' -Headers $headers
        Assert-MockCalled Invoke-RestMethod -ModuleName O365Essentials -ParameterFilter { $Headers.Authorization -eq 'Bearer arm' } -Exactly 1
    }
    It 'uses ARM headers for management endpoints' {
        $headers = [ordered]@{
            HeadersO365  = @{ Authorization = 'Bearer o365' }
            HeadersGraph = @{ Authorization = 'Bearer graph' }
            HeadersAzure = @{ Authorization = 'Bearer portal' }
            HeadersARM   = @{ Authorization = 'Bearer arm' }
        }
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        Mock -ModuleName O365Essentials Invoke-RestMethod -MockWith { }
        Invoke-O365Admin -Uri 'https://management.azure.com/providers/test' -Headers $headers
        Assert-MockCalled Invoke-RestMethod -ModuleName O365Essentials -ParameterFilter { $Headers.Authorization -eq 'Bearer arm' } -Exactly 1
    }
    It 'uses admin headers for admin.microsoft.com endpoints' {
        $headers = [ordered]@{
            HeadersO365  = @{ Authorization = 'Bearer o365' }
            HeadersGraph = @{ Authorization = 'Bearer graph' }
            HeadersAzure = @{ Authorization = 'Bearer portal' }
            HeadersARM   = @{ Authorization = 'Bearer arm' }
        }
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        Mock -ModuleName O365Essentials Invoke-RestMethod -MockWith { }
        Invoke-O365Admin -Uri 'https://admin.microsoft.com/admin/api/test' -Headers $headers
        Assert-MockCalled Invoke-RestMethod -ModuleName O365Essentials -ParameterFilter { $Headers.Authorization -eq 'Bearer o365' } -Exactly 1
    }
    It 'uses admin headers for admin.cloud.microsoft endpoints' {
        $headers = [ordered]@{
            HeadersO365  = @{ Authorization = 'Bearer o365' }
            HeadersGraph = @{ Authorization = 'Bearer graph' }
            HeadersAzure = @{ Authorization = 'Bearer portal' }
            HeadersARM   = @{ Authorization = 'Bearer arm' }
        }
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        Mock -ModuleName O365Essentials Invoke-RestMethod -MockWith { }
        Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/admin/api/test' -Headers $headers
        Assert-MockCalled Invoke-RestMethod -ModuleName O365Essentials -ParameterFilter { $Headers.Authorization -eq 'Bearer o365' } -Exactly 1
    }
    It 'uses portal session headers for admin.cloud.microsoft endpoints when requested' {
        $portalWebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
        $headers = [ordered]@{
            HeadersO365     = @{ Authorization = 'Bearer o365' }
            HeadersGraph    = @{ Authorization = 'Bearer graph' }
            HeadersAzure    = @{ Authorization = 'Bearer portal' }
            HeadersARM      = @{ Authorization = 'Bearer arm' }
            HeadersPortal   = @{ Accept = 'application/json'; AjaxSessionKey = 'ajax-key' }
            PortalWebSession = $portalWebSession
        }
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        Mock -ModuleName O365Essentials Invoke-RestMethod -MockWith { }
        Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/admin/api/test' -Headers $headers -UsePortalSession
        Assert-MockCalled Invoke-RestMethod -ModuleName O365Essentials -ParameterFilter {
            $Headers.Accept -eq 'application/json' -and
            $Headers.AjaxSessionKey -eq 'ajax-key' -and
            $WebSession -eq $portalWebSession
        } -Exactly 1
    }
    It 'does not refresh bearer auth when portal session replay is requested' {
        $portalWebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
        $headers = [ordered]@{
            HeadersPortal    = @{ Accept = 'application/json'; AjaxSessionKey = 'ajax-key' }
            PortalWebSession = $portalWebSession
        }
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { throw 'should not refresh' }
        Mock -ModuleName O365Essentials Invoke-RestMethod -MockWith { }

        { Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/admin/api/test' -Headers $headers -UsePortalSession } | Should -Not -Throw

        Assert-MockCalled Connect-O365Admin -ModuleName O365Essentials -Exactly 0
        Assert-MockCalled Invoke-RestMethod -ModuleName O365Essentials -ParameterFilter {
            $Headers.AjaxSessionKey -eq 'ajax-key' -and
            $WebSession -eq $portalWebSession
        } -Exactly 1
    }
    It 'uses Graph headers for graph endpoints' {
        $headers = [ordered]@{
            HeadersO365  = @{ Authorization = 'Bearer o365' }
            HeadersGraph = @{ Authorization = 'Bearer graph' }
            HeadersAzure = @{ Authorization = 'Bearer portal' }
            HeadersARM   = @{ Authorization = 'Bearer arm' }
        }
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        Mock -ModuleName O365Essentials Invoke-RestMethod -MockWith { }
        Invoke-O365Admin -Uri 'https://graph.microsoft.com/v1.0/test' -Headers $headers
        Assert-MockCalled Invoke-RestMethod -ModuleName O365Essentials -ParameterFilter { $Headers.Authorization -eq 'Bearer graph' } -Exactly 1
    }
    It 'merges additional headers into the selected header set' {
        $headers = [ordered]@{
            HeadersO365  = @{ Authorization = 'Bearer o365' }
            HeadersGraph = @{ Authorization = 'Bearer graph' }
            HeadersAzure = @{ Authorization = 'Bearer portal' }
            HeadersARM   = @{ Authorization = 'Bearer arm' }
        }
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        Mock -ModuleName O365Essentials Invoke-RestMethod -MockWith { }
        Invoke-O365Admin -Uri 'https://admin.microsoft.com/admin/api/test' -Headers $headers -AdditionalHeaders @{ Referer = 'https://admin.microsoft.com/' }
        Assert-MockCalled Invoke-RestMethod -ModuleName O365Essentials -ParameterFilter {
            $Headers.Authorization -eq 'Bearer o365' -and $Headers.Referer -eq 'https://admin.microsoft.com/'
        } -Exactly 1
    }
    It 'suppresses warnings when quiet error handling is requested' {
        $headers = [ordered]@{
            HeadersO365  = @{ Authorization = 'Bearer o365' }
            HeadersGraph = @{ Authorization = 'Bearer graph' }
            HeadersAzure = @{ Authorization = 'Bearer portal' }
            HeadersARM   = @{ Authorization = 'Bearer arm' }
        }
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        Mock -ModuleName O365Essentials Invoke-RestMethod -MockWith { throw 'boom' }
        Mock -ModuleName O365Essentials Write-Warning

        $Result = Invoke-O365Admin -Uri 'https://admin.microsoft.com/admin/api/test' -Headers $headers -QuietOnError

        $null -eq $Result | Should -BeTrue
        Assert-MockCalled Write-Warning -ModuleName O365Essentials -Exactly 0
    }
    It 'serializes array bodies for POST requests' {
        $headers = [ordered]@{
            HeadersO365  = @{ Authorization = 'Bearer o365' }
            HeadersGraph = @{ Authorization = 'Bearer graph' }
            HeadersAzure = @{ Authorization = 'Bearer portal' }
            HeadersARM   = @{ Authorization = 'Bearer arm' }
        }
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        Mock -ModuleName O365Essentials Invoke-RestMethod -MockWith { [pscustomobject]@{ ok = $true } }

        Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/admin/api/test' -Headers $headers -Method POST -Body @('alpha', 'beta') | Out-Null

        Assert-MockCalled Invoke-RestMethod -ModuleName O365Essentials -ParameterFilter {
            $ParsedBody = $Body | ConvertFrom-Json
            $Method -eq 'POST' -and
            $ParsedBody.Count -eq 2 -and
            $ParsedBody[0] -eq 'alpha' -and
            $ParsedBody[1] -eq 'beta'
        } -Exactly 1
    }
    It 'preserves explicit empty array GET responses' {
        $headers = [ordered]@{
            HeadersO365  = @{ Authorization = 'Bearer o365' }
            HeadersGraph = @{ Authorization = 'Bearer graph' }
            HeadersAzure = @{ Authorization = 'Bearer portal' }
            HeadersARM   = @{ Authorization = 'Bearer arm' }
        }
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        Mock -ModuleName O365Essentials Invoke-RestMethod -MockWith { , @() }

        $result = Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/admin/api/test' -Headers $headers

        $null -eq $result | Should -BeFalse
        $result -is [array] | Should -BeTrue
        $result.Count | Should -Be 0
    }
    It 'preserves empty value array GET responses' {
        $headers = [ordered]@{
            HeadersO365  = @{ Authorization = 'Bearer o365' }
            HeadersGraph = @{ Authorization = 'Bearer graph' }
            HeadersAzure = @{ Authorization = 'Bearer portal' }
            HeadersARM   = @{ Authorization = 'Bearer arm' }
        }
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        Mock -ModuleName O365Essentials Invoke-RestMethod -MockWith { [pscustomobject]@{ value = @() } }

        $result = Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/admin/api/test' -Headers $headers

        $null -eq $result | Should -BeFalse
        $result -is [array] | Should -BeTrue
        $result.Count | Should -Be 0
    }

    It 'retries admin.cloud.microsoft requests with portal replay after a 440 when portal state becomes available' {
        $portalWebSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
        $headers = [ordered]@{
            HeadersO365   = @{ Authorization = 'Bearer o365' }
            HeadersGraph  = @{ Authorization = 'Bearer graph' }
            HeadersAzure  = @{ Authorization = 'Bearer portal' }
            HeadersARM    = @{ Authorization = 'Bearer arm' }
        }
        $portalHeaders = [ordered]@{
            HeadersO365      = @{ Authorization = 'Bearer o365' }
            HeadersGraph     = @{ Authorization = 'Bearer graph' }
            HeadersAzure     = @{ Authorization = 'Bearer portal' }
            HeadersARM       = @{ Authorization = 'Bearer arm' }
            HeadersPortal    = @{ Accept = 'application/json'; AjaxSessionKey = 'ajax-key' }
            PortalWebSession = $portalWebSession
        }

        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith {
            param($Headers)
            if ($Headers -eq $portalHeaders) {
                return $portalHeaders
            }
            $script:connectCallCount = ($script:connectCallCount + 1)
            if ($script:connectCallCount -eq 1) {
                return $headers
            }
            return $portalHeaders
        }
        Mock -ModuleName O365Essentials Invoke-RestMethod -MockWith {
            if (-not $WebSession) {
                throw 'Response status code does not indicate success: 440 ().'
            }
            [pscustomobject]@{ ok = $true; usedPortal = $true }
        }

        $result = Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/admin/api/test' -Headers $headers

        $result.ok | Should -BeTrue
        Assert-MockCalled Connect-O365Admin -ModuleName O365Essentials -Exactly 2
        Assert-MockCalled Invoke-RestMethod -ModuleName O365Essentials -ParameterFilter {
            $WebSession -eq $portalWebSession -and
            $Headers.AjaxSessionKey -eq 'ajax-key'
        } -Exactly 1
    }

    It 'does not recurse indefinitely when a 440 cannot be upgraded to portal replay' {
        $headers = [ordered]@{
            HeadersO365  = @{ Authorization = 'Bearer o365' }
            HeadersGraph = @{ Authorization = 'Bearer graph' }
            HeadersAzure = @{ Authorization = 'Bearer portal' }
            HeadersARM   = @{ Authorization = 'Bearer arm' }
        }
        Mock -ModuleName O365Essentials Connect-O365Admin -MockWith { param($Headers) $Headers }
        Mock -ModuleName O365Essentials Invoke-RestMethod -MockWith { throw 'Response status code does not indicate success: 440 ().' }
        Mock -ModuleName O365Essentials Write-Warning

        $result = Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/admin/api/test' -Headers $headers -QuietOnError

        $null -eq $result | Should -BeTrue
        Assert-MockCalled Connect-O365Admin -ModuleName O365Essentials -Exactly 2
        Assert-MockCalled Write-Warning -ModuleName O365Essentials -Exactly 0
    }
}

