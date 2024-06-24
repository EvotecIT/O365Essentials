function Get-O365DomainHealth {
    <#
        .SYNOPSIS
        Provides functionality to check the DNS health of a specified domain in Office 365.
        .DESCRIPTION
        This function allows you to query and check the DNS health of a specific domain in Office 365 using the provided headers.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .PARAMETER DomainName
        The name of the domain for which to check DNS health.
        .EXAMPLE
        Get-O365DomainHealth -Headers $headers -DomainName 'example.com'
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][string] $DomainName
    )
    $Uri = "https://admin.microsoft.com/admin/api/Domains/CheckDnsHealth"

    $QueryParameter = @{
        'domainName'             = $DomainName
        'overrideSkip'           = $true
        'canRefreshCache'        = $true
        'dnsHealthCheckScenario' = 2
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter
    if ($Output.Succeeded) {
        $Output.Data
    } else {
        $Output
    }
}

<#
function Get-O365DomainRegistrarsInformation {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers #,
       # [parameter(Mandatory)][string] $DomainName
    )
    $Uri = "https://admin.microsoft.com/admin/api/Domains/GetRegistrarsHelpInfo"

    $QueryParameter = @{
        #'domainName'             = $DomainName
        #'overrideSkip'           = $true
        #'canRefreshCache'        = $true
        #'dnsHealthCheckScenario' = 2
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter
    $Output
}
#>
