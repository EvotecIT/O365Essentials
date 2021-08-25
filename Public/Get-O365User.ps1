function Get-O365User {
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
        [string] $OrderBy
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
    Remove-EmptyValue -Hashtable $QueryParameter
    Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter
}