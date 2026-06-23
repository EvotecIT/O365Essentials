Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365BillingProfile' {
    It 'uses the provided billing account id' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365BillingProfile -Headers @{ HeadersO365 = @{ Authorization = 'Bearer token' } } -AccountId 'billing-account-1' | Out-Null

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://admin.microsoft.com/fd/commerceMgmt/moderncommerce/myroles/BillingGroup' -and
            $Method -eq 'GET' -and
            $QueryParameter['api-version'] -eq '3.0' -and
            $QueryParameter.accountId -eq 'billing-account-1'
        } -Exactly 1
    }

    It 'auto-discovers an account id from billing accounts' {
        Mock -ModuleName O365Essentials Get-O365BillingAccounts -MockWith { [pscustomobject]@{ accountId = 'auto-account' } }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365BillingProfile -Headers @{ HeadersO365 = @{ Authorization = 'Bearer token' } } | Out-Null

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $QueryParameter.accountId -eq 'auto-account'
        } -Exactly 1
    }

    It 'does not call the billing profile endpoint when account id cannot be resolved' {
        Mock -ModuleName O365Essentials Get-O365BillingAccounts -MockWith { $null }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }
        Mock -ModuleName O365Essentials Write-Warning

        Get-O365BillingProfile -Headers @{ HeadersO365 = @{ Authorization = 'Bearer token' } } | Out-Null

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -Exactly 0
        Assert-MockCalled Write-Warning -ModuleName O365Essentials -ParameterFilter {
            $Message -like 'Get-O365BillingProfile - AccountId could not be resolved*'
        } -Exactly 1
    }
}
