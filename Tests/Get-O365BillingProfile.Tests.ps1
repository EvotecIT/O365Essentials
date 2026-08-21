Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Get-O365BillingProfile' {
    It 'uses a provided billing account name with the documented ARM endpoint' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365BillingProfile -Headers @{ HeadersO365 = @{ Authorization = 'Bearer token' } } -AccountId 'billing-account-1' | Out-Null

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://management.azure.com/providers/Microsoft.Billing/billingAccounts/billing-account-1/billingProfiles' -and
            $Method -eq 'GET' -and
            $QueryParameter['api-version'] -eq '2024-04-01' -and
            $ErrorAction -eq 'Stop'
        } -Times 1 -Exactly
    }

    It 'auto-discovers accounts that support billing profiles' {
        Mock -ModuleName O365Essentials Get-O365BillingAccounts -MockWith {
            [pscustomobject]@{ name = 'customer-account'; properties = [pscustomobject]@{ agreementType = 'MicrosoftCustomerAgreement' } }
            [pscustomobject]@{ name = 'online-services-account'; properties = [pscustomobject]@{ agreementType = 'MicrosoftOnlineServicesProgram' } }
            [pscustomobject]@{ name = 'partner-account'; properties = [pscustomobject]@{ agreementType = 'MicrosoftPartnerAgreement' } }
        }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365BillingProfile -Headers @{ HeadersO365 = @{ Authorization = 'Bearer token' } } | Out-Null

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -like '*/billingAccounts/customer-account/billingProfiles'
        } -Times 1 -Exactly
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -like '*/billingAccounts/partner-account/billingProfiles'
        } -Times 1 -Exactly
        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -like '*online-services-account*'
        } -Times 0 -Exactly
    }

    It 'does not call the billing profile endpoint when no supported account can be resolved' {
        Mock -ModuleName O365Essentials Get-O365BillingAccounts -MockWith { $null }
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }
        Mock -ModuleName O365Essentials Write-Warning

        Get-O365BillingProfile -Headers @{ HeadersO365 = @{ Authorization = 'Bearer token' } } | Out-Null

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -Times 0 -Exactly
        Should -Invoke -CommandName Write-Warning -ModuleName O365Essentials -ParameterFilter {
            $Message -like 'Get-O365BillingProfile - No billing account that supports billing profiles could be resolved*'
        } -Times 1 -Exactly
    }

    It 'escapes billing account names used in the resource path' {
        Mock -ModuleName O365Essentials Invoke-O365Admin

        Get-O365BillingProfile -AccountId 'account:tenant_2024' | Out-Null

        Should -Invoke -CommandName Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri.AbsoluteUri -like '*/billingAccounts/account%3Atenant_2024/billingProfiles'
        } -Times 1 -Exactly
    }
}
