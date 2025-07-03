function Get-O365AzureElevatedDenyAssignments {
    <#
    .SYNOPSIS
    Lists deny assignments for the specified principal at root scope.

    .DESCRIPTION
    Retrieves deny assignments for a principal after elevation using the Azure management API.

    .PARAMETER Headers
    Authentication headers obtained from Connect-O365Admin.

    .PARAMETER PrincipalId
    Object ID of the principal to query.

    .PARAMETER UserPrincipalName
    User principal name of the principal to query. This will be automatically
    resolved to the corresponding object ID.

    .PARAMETER ApiVersion
    API version to use. Defaults to '2022-04-01'.

    .EXAMPLE
    Get-O365AzureElevatedDenyAssignments -Headers $headers -PrincipalId $UserId

    .EXAMPLE
    Get-O365AzureElevatedDenyAssignments -UserPrincipalName 'admin@contoso.com'
    #>
    [cmdletbinding(DefaultParameterSetName = 'Id')]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(ParameterSetName='Id')][string] $PrincipalId,
        [parameter(ParameterSetName='UPN')][string] $UserPrincipalName,
        [string] $ApiVersion = '2022-04-01'
    )
    if ($UserPrincipalName) {
        $user = Get-O365User -Headers $Headers -UserPrincipalName $UserPrincipalName -Property id -WarningAction SilentlyContinue
        if ($user) {
            $PrincipalId = if ($user.value) { $user.value[0].id } else { $user.id }
        } else {
            Write-Warning "Get-O365AzureElevatedDenyAssignments - User '$UserPrincipalName' not found"
            return
        }
    }
    $Uri = 'https://management.azure.com/providers/Microsoft.Authorization/denyAssignments'
    $QueryParameter = @{ 'api-version' = $ApiVersion; '$filter' = "gdprExportPrincipalId eq '$PrincipalId'" }
    Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -QueryParameter $QueryParameter
}
