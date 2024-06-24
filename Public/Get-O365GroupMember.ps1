function Get-O365GroupMember {
    <#
        .SYNOPSIS
        Retrieves members of an Office 365 group based on the provided group ID.
        .DESCRIPTION
        This function queries the Microsoft Graph API to retrieve members of an Office 365 group using the specified group ID.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .PARAMETER Id
        The ID of the Office 365 group for which members are to be retrieved.
        .PARAMETER Search
        A search query to filter the members of the group.
        .PARAMETER Property
        An array of properties to include in the query results.
        .EXAMPLE
        Get-O365GroupMember -Headers $headers -Id 'groupID' -Search 'searchQuery' -Property @('property1', 'property2')
    #>
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
