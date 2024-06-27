function Get-O365DomainTroubleshooting {
    <#
    .SYNOPSIS
    Provides troubleshooting information for a specified domain in Office 365.

    .DESCRIPTION
    This function allows you to check if troubleshooting is allowed for a specific domain in Office 365 using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER DomainName
    The name of the domain to check troubleshooting for.

    .EXAMPLE
    Get-O365DomainTroubleshooting -Headers $headers -DomainName 'example.com'
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][string] $DomainName
    )
    $Uri = "https://admin.microsoft.com/admin/api/Domains/CheckIsTroubleshootingAllowed"

    $QueryParameter = @{
        'domainName'      = $DomainName
        #'overrideSkip'           = $true
        'canRefreshCache' = $true
        #'dnsHealthCheckScenario' = 2
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter
    $Output
}
