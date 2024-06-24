function Get-O365User {
    <#
    .SYNOPSIS
    Provides functionality to retrieve Office 365 user information based on various parameters.

    .DESCRIPTION
    This function allows you to query and retrieve user information from Office 365 based on different criteria such as UserPrincipalName, EmailAddress, and ID.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER Id
    The ID of the user to query.

    .PARAMETER UserPrincipalName
    The UserPrincipalName of the user to query.

    .PARAMETER EmailAddress
    The email address of the user to query.

    .PARAMETER Property
    An array of properties to include in the query response.

    .PARAMETER Filter
    The filter to apply to the query.

    .PARAMETER GuestsOnly
    Switch parameter to query only guest users.

    .PARAMETER OrderBy
    The property to order the query results by.

    .EXAMPLE
    Get-O365User -Headers $headers -UserPrincipalName 'john.doe@example.com' -Property @('displayName', 'jobTitle')

    .NOTES
    For more information, visit: https://docs.microsoft.com/en-us/graph/api/user-get?view=graph-rest-1.0
    #>
    [cmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [parameter(ParameterSetName = 'Default')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'GuestsOnly')]
        [parameter(ParameterSetName = 'EmailAddress')]
        [parameter(ParameterSetName = 'UserPrincipalName')]
        [parameter(ParameterSetName = 'Id')]
        [parameter()][alias('Authorization')][System.Collections.IDictionary] $Headers,

        [parameter(ParameterSetName = 'Id')][string] $Id,

        [parameter(ParameterSetName = 'UserPrincipalName')][string] $UserPrincipalName,

        [alias('Mail')][parameter(ParameterSetName = 'EmailAddress')][string] $EmailAddress,

        [parameter(ParameterSetName = 'Default')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'GuestsOnly')]
        [parameter(ParameterSetName = 'EmailAddress')]
        [parameter(ParameterSetName = 'UserPrincipalName')]
        [parameter(ParameterSetName = 'Id')]
        [string[]] $Property,

        [parameter(ParameterSetName = 'Default')]
        [parameter(ParameterSetName = 'Filter')][string] $Filter,

        [parameter(ParameterSetName = 'GuestsOnly')][switch] $GuestsOnly,

        [parameter(ParameterSetName = 'GuestsOnly')]
        [parameter(ParameterSetName = 'Default')]
        [parameter(ParameterSetName = 'Filter')]
        [string] $OrderBy,

        [parameter(ParameterSetName = 'Default')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'GuestsOnly')]
        [parameter(ParameterSetName = 'EmailAddress')]
        [parameter(ParameterSetName = 'UserPrincipalName')]
        [parameter(ParameterSetName = 'Id')]
        [switch] $IncludeManager
    )
    if ($GuestsOnly) {
        $Uri = 'https://graph.microsoft.com/v1.0/users'
        $QueryParameter = @{
            '$Select'  = $Property -join ','
            '$filter'  = "userType eq 'Guest'"
            '$orderby' = $OrderBy
        }
    } elseif ($UserPrincipalName) {
        $Uri = 'https://graph.microsoft.com/v1.0/users'
        $QueryParameter = @{
            '$Select' = $Property -join ','
            '$filter' = "userPrincipalName eq '$UserPrincipalName'"
        }
    } elseif ($EmailAddress) {
        $Uri = 'https://graph.microsoft.com/v1.0/users'
        $QueryParameter = @{
            '$Select' = $Property -join ','
            '$filter' = "mail eq '$EmailAddress'"
        }
    } elseif ($ID) {
        # Query a single group
        $Uri = "https://graph.microsoft.com/v1.0/users/$ID"
        $QueryParameter = @{
            '$Select' = $Property -join ','
        }
    } else {
        # Query multiple groups
        $Uri = 'https://graph.microsoft.com/v1.0/users'
        $QueryParameter = @{
            '$Select'  = $Property -join ','
            # https://docs.microsoft.com/en-us/graph/query-parameters#filter-parameter
            '$filter'  = $Filter
            '$orderby' = $OrderBy
        }
    }
    # https://docs.microsoft.com/en-us/graph/api/user-list-manager?view=graph-rest-1.0&tabs=http
    if ($IncludeManager) {
        $QueryParameter['$expand'] = 'manager'
    }
    Remove-EmptyValue -Hashtable $QueryParameter
    Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter
}
