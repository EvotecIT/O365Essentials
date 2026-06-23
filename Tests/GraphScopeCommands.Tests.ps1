Import-Module "$PSScriptRoot/../O365Essentials.psd1" -Force

Describe 'Graph commands with required scopes' {
    It 'uses the current named locations endpoint and requests Policy.Read.All' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365AzureConditionalAccessLocation -Headers @{ HeadersGraph = @{ Authorization = 'Bearer graph' } } | Out-Null

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations' -and
            $RequiredGraphScope -contains 'Policy.Read.All|Policy.ReadWrite.ConditionalAccess' -and
            $QueryParameter['$top'] -eq 10 -and
            $QueryParameter['$orderby'] -eq 'displayName'
        } -Exactly 1
    }

    It 'requests Policy.Read.All for authentication flows policy' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365AzureExternalCollaborationFlows -Headers @{ HeadersGraph = @{ Authorization = 'Bearer graph' } } | Out-Null

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://graph.microsoft.com/v1.0/policies/authenticationFlowsPolicy' -and
            $RequiredGraphScope -contains 'Policy.Read.All|Policy.ReadWrite.AuthenticationFlows'
        } -Exactly 1
    }

    It 'uses the current email authentication method endpoint and scope' {
        Mock -ModuleName O365Essentials Invoke-O365Admin -MockWith { }

        Get-O365AzureExternalIdentitiesEmail -Headers @{ HeadersGraph = @{ Authorization = 'Bearer graph' } } | Out-Null

        Assert-MockCalled Invoke-O365Admin -ModuleName O365Essentials -ParameterFilter {
            $Uri -eq 'https://graph.microsoft.com/v1.0/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/email' -and
            $RequiredGraphScope -contains 'Policy.Read.AuthenticationMethod|Policy.ReadWrite.AuthenticationMethod'
        } -Exactly 1
    }
}
