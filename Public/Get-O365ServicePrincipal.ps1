function Get-O365ServicePrincipal {
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