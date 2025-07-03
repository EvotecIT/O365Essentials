function Set-O365AzureElevatedAccess {
    <#
    .SYNOPSIS
    Elevates the current user's permissions to User Access Administrator.

    .DESCRIPTION
    Sends a request to the Azure management endpoint to grant User Access Administrator role at the root scope.

    .PARAMETER Headers
    Authentication headers obtained from Connect-O365Admin.

    .PARAMETER ApiVersion
    API version to use. Defaults to '2016-07-01'.

    .EXAMPLE
    Set-O365AzureElevatedAccess -Headers $headers
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [string] $ApiVersion = '2016-07-01'
    )
    $Uri = 'https://management.azure.com/providers/Microsoft.Authorization/elevateAccess'
    $QueryParameter = @{ 'api-version' = $ApiVersion }
    if ($PSCmdlet.ShouldProcess($Uri, 'Elevate access')) {
        Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -QueryParameter $QueryParameter
    }
}
