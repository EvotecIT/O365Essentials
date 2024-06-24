function Get-O365DomainDependencies {
    <#
    .SYNOPSIS
    Provides functionality to retrieve domain dependencies in Office 365.

    .DESCRIPTION
    This function allows you to query and retrieve dependencies related to a specific domain in Office 365 using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER DomainName
    The name of the domain for which to retrieve dependencies.

    .PARAMETER Type
    Specifies the type of dependencies to retrieve. Valid values are 'All', 'Users', 'TeamsAndGroups', and 'Apps'. Default is 'All'.

    .EXAMPLE
    Get-O365DomainDependencies -Headers $headers -DomainName 'example.com' -Type 'Users'
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][string] $DomainName,
        [string][ValidateSet('All', 'Users', 'TeamsAndGroups', 'Apps')] $Type = 'All'
    )
    $Uri = "https://admin.microsoft.com/admin/api/Domains/Dependencies"

    $Types = @{
        'All'    = 0
        'Users'  = 1
        'Groups' = 2
        'Apps'   = 4
    }

    $QueryParameter = @{
        'domainName' = $DomainName
        'kind'       = $Types[$Type]
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter -Method POST
    if ($Output.Succeeded) {
        $Output.Data.Dependencies
    } else {
        [PSCustomObject] @{
            DomainName = $DomainName
            Status     = $false
            Message    = $Output.Message
        }
    }
}
