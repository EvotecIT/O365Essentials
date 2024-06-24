function Get-O365Group {
    <#
        .SYNOPSIS
        Provides functionality to retrieve Office 365 group information based on various parameters.
        .DESCRIPTION
        This function allows you to query and retrieve group information from Office 365 based on different criteria such as ID, display name, email address, and more.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .PARAMETER Id
        The ID of the group to query.
        .PARAMETER DisplayName
        The display name of the group to query.
        .PARAMETER EmailAddress
        The email address of the group to query.
        .PARAMETER Property
        An array of properties to include in the query response.
        .PARAMETER Filter
        The filter to apply to the query.
        .PARAMETER OrderBy
        The property to order the query results by.
        .EXAMPLE
        Get-O365Group -Headers $headers -DisplayName 'MyGroup' -Property @('displayName', 'mail')
    #>
    [cmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [parameter(ParameterSetName = 'UnifiedGroupsOnly')]
        [parameter(ParameterSetName = 'Default')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'EmailAddress')]
        [parameter(ParameterSetName = 'DisplayName')]
        [parameter(ParameterSetName = 'Id')]
        [alias('Authorization')][System.Collections.IDictionary] $Headers,

        [parameter(ParameterSetName = 'Id')][string] $Id,

        [parameter(ParameterSetName = 'DisplayName')][string] $DisplayName,

        [alias('Mail')][parameter(ParameterSetName = 'EmailAddress')][string] $EmailAddress,

        [parameter(ParameterSetName = 'UnifiedGroupsOnly')]
        [parameter(ParameterSetName = 'Default')]
        [parameter(ParameterSetName = 'Filter')]
        [parameter(ParameterSetName = 'EmailAddress')]
        [parameter(ParameterSetName = 'DisplayName')]
        [parameter(ParameterSetName = 'Id')]
        [string[]] $Property,

        [parameter(ParameterSetName = 'Default')]
        [parameter(ParameterSetName = 'Filter')][string] $Filter,

        [parameter(ParameterSetName = 'UnifiedGroupsOnly')]
        [parameter(ParameterSetName = 'Default')]
        [parameter(ParameterSetName = 'Filter')]
        [string] $OrderBy,

        [parameter(ParameterSetName = 'UnifiedGroupsOnly')]
        [switch] $UnifiedGroupsOnly
    )
    if ($DisplayName) {
        $Uri = 'https://graph.microsoft.com/v1.0/groups'
        $QueryParameter = @{
            '$Select' = $Property -join ','
            '$filter' = "displayName eq '$DisplayName'"
        }
    } elseif ($EmailAddress) {
        $Uri = 'https://graph.microsoft.com/v1.0/groups'
        $QueryParameter = @{
            '$Select' = $Property -join ','
            '$filter' = "mail eq '$EmailAddress'"
        }
    } elseif ($ID) {
        # Query a single group
        $Uri = "https://graph.microsoft.com/v1.0/groups/$ID"
        $QueryParameter = @{
            '$Select' = $Property -join ','
        }
    } elseif ($UnifiedGroupsOnly) {
        $Uri = "https://graph.microsoft.com/v1.0/groups"
        $QueryParameter = @{
            '$Select'  = $Property -join ','
            '$filter'  = "groupTypes/any(c: c eq 'Unified')"
            '$orderby' = $OrderBy
        }
    } else {
        # Query multiple groups
        $Uri = 'https://graph.microsoft.com/v1.0/groups'
        $QueryParameter = @{
            '$Select'  = $Property -join ','
            '$filter'  = $Filter
            '$orderby' = $OrderBy
        }
    }
    Remove-EmptyValue -Hashtable $QueryParameter
    Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter
}
