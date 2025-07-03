function Get-O365AzureElevatedRoleAssignments {
    <#
    .SYNOPSIS
    Lists role assignments for the specified principal at root scope.

    .DESCRIPTION
    Retrieves role assignments for a principal after elevation using the Azure management API.

    .PARAMETER Headers
    Authentication headers obtained from Connect-O365Admin.

    .PARAMETER PrincipalId
    Object ID of the principal to query.

    .PARAMETER ApiVersion
    API version to use. Defaults to '2022-04-01'.

    .EXAMPLE
    Get-O365AzureElevatedRoleAssignments -Headers $headers -PrincipalId $UserId
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][string] $PrincipalId,
        [string] $ApiVersion = '2022-04-01'
    )
    $Uri = 'https://management.azure.com/providers/Microsoft.Authorization/roleAssignments'
    $QueryParameter = @{ 'api-version' = $ApiVersion; '$filter' = "principalId eq '$PrincipalId'" }
    Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -QueryParameter $QueryParameter
}
