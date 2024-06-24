function Get-O365BillingSubscriptions {
    <#
    .SYNOPSIS
    Retrieves billing subscriptions for a specific organization in Office 365.

    .DESCRIPTION
    This function retrieves billing subscriptions for a specified organization in Office 365 from the designated API endpoint using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER Property
    An array of properties to include in the query response.

    .PARAMETER OrderBy
    The property to order the query results by.

    .EXAMPLE
    Get-O365BillingSubscriptions -Headers $headers -Property @('displayName', 'status') -OrderBy 'displayName'
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [string[]]$Property,
        [string] $OrderBy
    )

    #$Uri = "https://admin.microsoft.com/fd/commerceapi/my-org/subscriptions?`$filter=parentId%20eq%20null&`$expand=subscribedsku&optional=cspsubscriptions,price,actions,transitiondetails,quickstarttag"
    $Uri = "https://admin.microsoft.com/fd/commerceapi/my-org/subscriptions"

    $QueryParameter = @{
        '$Select'  = $Property -join ','
        '$filter'  = 'parentId eq null'
        '$orderby' = $OrderBy
        'expand'   = 'subscribedsku'
        'optional' = "cspsubscriptions,price,actions,transitiondetails,quickstarttag"
    }
    Remove-EmptyValue -Hashtable $QueryParameter

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter
    $Output
}
