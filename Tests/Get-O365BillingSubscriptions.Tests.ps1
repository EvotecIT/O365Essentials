Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365BillingSubscriptions' {
    It 'requests subscribedSku through the OData expand parameter' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365BillingSubscriptions -Headers @{ HeadersO365 = @{ Authorization = 'Bearer token' } } | Out-Null

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.microsoft.com/fd/commerceapi/my-org/subscriptions' -and
            $QueryParameter['$expand'] -eq 'subscribedsku' -and
            -not $QueryParameter.Contains('expand')
        } -Exactly 1
    }
}
