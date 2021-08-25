function Get-O365Group {
    [cmdletBinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [string] $Id,
        [string[]] $Property,
        [string] $Filter,
        [string] $OrderBy
    )
    if ($ID) {
        # Query a single group
        $Uri = "https://graph.microsoft.com/v1.0/groups/$ID"
        $QueryParameter = @{
            '$Select' = $Property -join ','
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