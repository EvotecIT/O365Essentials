function Get-O365GroupMember {
    [cmdletBinding()]
    param(
        [parameter()][alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][string] $Id,
        [string] $Search,
        [string[]] $Property
    )
    if ($ID) {
        # Query a single group
        $Uri = "https://graph.microsoft.com/v1.0/groups/$ID/members"
        $QueryParameter = @{
            '$Select' = $Property -join ','
            '$Search' = $Search

        }
        if ($QueryParameter.'$Search') {
            # This is required for search to work
            # https://developer.microsoft.com/en-us/identity/blogs/build-advanced-queries-with-count-filter-search-and-orderby/
            $Headers['ConsistencyLevel'] = 'eventual'
        }

        Remove-EmptyValue -Hashtable $QueryParameter
        Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter
    }
}