Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365BillingAccounts' {
    It 'lists accounts through the documented Microsoft Billing ARM endpoint' {
        Mock -ModuleName O365Essentials Invoke-O365Admin

        Get-O365BillingAccounts -Headers @{ HeadersARM = @{ Authorization = 'Bearer arm' } } | Out-Null

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://management.azure.com/providers/Microsoft.Billing/billingAccounts' -and
            $Method -eq 'GET' -and
            $QueryParameter['api-version'] -eq '2024-04-01' -and
            $ErrorAction -eq 'Stop'
        } -Times 1 -Exactly
    }
}
