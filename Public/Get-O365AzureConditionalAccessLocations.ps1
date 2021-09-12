function Get-O365AzureConditionalAccessLocation {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://graph.microsoft.com/beta/conditionalAccess/namedLocations'

    #?`$filter=&`$orderby=displayName&`$skip=0&`$top=10&`$count=true

    $QueryParameters = @{
        top     = 10
        skip    = 0
        orderby = 'displayName'
        filter  = ''
        count   = 'true'
    }

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameters
    if ($Output) {
        $Output
    }
}