function Get-O365Group {
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