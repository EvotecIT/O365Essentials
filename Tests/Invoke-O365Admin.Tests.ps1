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
}

