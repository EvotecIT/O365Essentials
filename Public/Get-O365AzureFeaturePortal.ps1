function Get-O365AzureFeaturePortal {
    <#
    .SYNOPSIS
    Retrieves the Azure feature portal information.

    .DESCRIPTION
    This function fetches the Azure feature portal information using the provided headers or attempts to fetch them from the current execution context if not provided.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information. If not provided, the function will attempt to fetch it from the current execution context.

    .EXAMPLE
    Get-O365AzureFeaturePortal -Headers $headers

    .NOTES
    This function is designed to work in conjunction with Connect-O365Admin to fetch the necessary headers for authentication. It retrieves the Azure feature portal information, which includes various settings and configurations.
    #>
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