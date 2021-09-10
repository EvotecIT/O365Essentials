function Get-O365BillingSubscriptions {
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