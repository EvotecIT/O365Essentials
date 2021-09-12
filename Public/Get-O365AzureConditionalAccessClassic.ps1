function Get-O365AzureConditionalAccessClassic {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://main.iam.ad.ext.azure.com/api/ClassicPolicies'

    $QueryParameters = @{
        top      = 10
        nextLink = $null
        filter   = 1
    }

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameters
    if ($Output.items) {
        $Output.items
    }
}