function Get-O365AzureFeatureConfiguration {
    <#
    .SYNOPSIS
    Retrieves Azure feature configuration information.

    .DESCRIPTION
    This function fetches the Azure feature configuration information using the provided headers or attempts to fetch them from the current execution context if not provided.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information. If not provided, the function will attempt to fetch it from the current execution context.

    .EXAMPLE
    Get-O365AzureFeatureConfiguration -Headers $headers

    .NOTES
    This function is designed to work in conjunction with Connect-O365Admin to fetch the necessary headers for authentication. It retrieves the Azure feature configuration information, which includes various settings and configurations.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://main.iam.ad.ext.azure.com/api/FeatureConfigurations?supportAU=false'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        $Output
    }
}