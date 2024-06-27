function Get-O365DomainRecords {
    <#
    .SYNOPSIS
    Provides functionality to retrieve domain records for a specified domain in Office 365.

    .DESCRIPTION
    This function allows you to query and retrieve domain records for a specific domain in Office 365 using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER DomainName
    The name of the domain for which to retrieve records.

    .EXAMPLE
    Get-O365DomainRecords -Headers $headers -DomainName 'example.com'
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][string] $DomainName
    )
    $Uri = "https://admin.microsoft.com/admin/api/Domains/Records"

    $QueryParameter = @{
        'domainName' = $DomainName
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter
    $Output
}
