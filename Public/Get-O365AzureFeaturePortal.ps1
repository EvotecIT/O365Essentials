function Get-O365AzureFeaturePortal {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://afd.hosting.portal.azure.net/iam/?bundlingKind=DefaultPartitioner&cacheability=3&clientOptimizations=true&environmentjson=true&extensionName=Microsoft_AAD_IAM&l=en&pageVersion=3.0.01692206&trustedAuthority=portal.azure.com'


    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        $Output
    }
}