function Get-O365ServicePrincipal {
    <#
    .SYNOPSIS
    Retrieves information about Office 365 service principals based on various parameters.

    .DESCRIPTION
    This function allows you to query and retrieve service principal information from Office 365 based on different criteria such as ID, display name, service principal type, and more.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER Id
    The ID of the service principal to query.

    .PARAMETER DisplayName
    The display name of the service principal to query.

    .PARAMETER ServicePrincipalType
    The type of service principal to query. Valid values are 'Application', 'Legacy', 'SocialIdp'.

    .PARAMETER Property
    An array of properties to include in the query response.

    .PARAMETER Filter
    The filter to apply to the query.

    .PARAMETER GuestsOnly
    Switch parameter to query only guest service principals.

    .PARAMETER OrderBy
    The property to order the query results by.

    .EXAMPLE
    Get-O365ServicePrincipal -Headers $headers -DisplayName 'MyApp' -Property @('displayName', 'appId')
    #>
    [cmdletBinding(DefaultParameterSetName = "Default")]
    param(
        [parameter(ParameterSetName = 'Default')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'GuestsOnly')]
        [parameter(ParameterSetName = 'ServicePrincipalType')]
        [parameter(ParameterSetName = 'AppDisplayName')]
        [parameter(ParameterSetName = 'Id')]
        [parameter()][alias('Authorization')][System.Collections.IDictionary] $Headers,

        [parameter(ParameterSetName = 'Id')][string] $Id,

        [parameter(ParameterSetName = 'AppDisplayName')][string] $DisplayName,

        [ValidateSet('Application', 'Legacy', 'SocialIdp')][parameter(ParameterSetName = 'servicePrincipalType')][string] $ServicePrincipalType,

        [parameter(ParameterSetName = 'Default')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'GuestsOnly')]
        [parameter(ParameterSetName = 'ServicePrincipalType')]
        [parameter(ParameterSetName = 'AppDisplayName')]
        [parameter(ParameterSetName = 'Id')]
        [string[]] $Property,

        [parameter(ParameterSetName = 'Default')]
        [parameter(ParameterSetName = 'Filter')][string] $Filter,

        [parameter(ParameterSetName = 'GuestsOnly')][switch] $GuestsOnly,

        [parameter(ParameterSetName = 'GuestsOnly')]
        [parameter(ParameterSetName = 'Default')]
        [parameter(ParameterSetName = 'Filter')]
        [string] $OrderBy
    )
    if ($GuestsOnly) {
        $Uri = 'https://graph.microsoft.com/v1.0/servicePrincipals'
        $QueryParameter = @{
            '$Select'  = $Property -join ','
            '$filter'  = "userType eq 'Guest'"
            '$orderby' = $OrderBy
        }
    } elseif ($DisplayName) {
        $Uri = 'https://graph.microsoft.com/v1.0/servicePrincipals'
        $QueryParameter = @{
            '$Select' = $Property -join ','
            '$filter' = "displayName eq '$DisplayName'"
        }
    } elseif ($ServicePrincipalType) {
        $Uri = 'https://graph.microsoft.com/v1.0/servicePrincipals'
        $QueryParameter = @{
            '$Select' = $Property -join ','
            '$filter' = "servicePrincipalType eq '$ServicePrincipalType'"
        }
    } elseif ($ID) {
        # Query a single group
        $Uri = "https://graph.microsoft.com/v1.0/servicePrincipals/$ID"
        $QueryParameter = @{
            '$Select' = $Property -join ','
        }
    } else {
        # Query multiple groups
        $Uri = 'https://graph.microsoft.com/v1.0/servicePrincipals'
        $QueryParameter = @{
            '$Select'  = $Property -join ','
            # https://docs.microsoft.com/en-us/graph/query-parameters#filter-parameter
            '$filter'  = $Filter
            '$orderby' = $OrderBy
        }
    }
    Remove-EmptyValue -Hashtable $QueryParameter
    Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter
}
