function Get-O365PasswordReset {
    <#
    .SYNOPSIS
    Retrieves password reset policies from the specified endpoint.

    .DESCRIPTION
    This function retrieves password reset policies from the specified API endpoint using the provided headers.

    .PARAMETER Headers
    Authentication token and additional information for the API request.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/PasswordReset/PasswordResetPolicies"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
