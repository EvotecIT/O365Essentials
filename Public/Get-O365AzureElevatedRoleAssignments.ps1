function Get-O365AzureElevatedRoleAssignments {
    <#
    .SYNOPSIS
    Lists role assignments for the specified principal at root scope. If no
    principal is provided the current user is used.

    .DESCRIPTION
    Retrieves role assignments for a principal after elevation using the Azure management API.

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
    Get-O365AzureElevatedRoleAssignments -Headers $headers -PrincipalId $UserId

    .EXAMPLE
    Get-O365AzureElevatedRoleAssignments -UserPrincipalName 'admin@contoso.com'

    .EXAMPLE
    # Query assignments for the current user
    Get-O365AzureElevatedRoleAssignments
    #>
    [cmdletbinding(DefaultParameterSetName = 'Self')]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(ParameterSetName='Id')][string] $PrincipalId,
        [parameter(ParameterSetName='UPN')][string] $UserPrincipalName,
        [string] $ApiVersion = '2022-04-01'
    )
    $Headers = Connect-O365Admin -Headers $Headers
    if (-not $Headers.HeadersAzure) {
        Write-Warning 'Get-O365AzureElevatedRoleAssignments - Azure token not available. Ensure Connect-O365Admin has permission to access https://management.azure.com.'
        return
    }
    if ($UserPrincipalName) {
        $user = Get-O365User -Headers $Headers -UserPrincipalName $UserPrincipalName -Property id -WarningAction SilentlyContinue
        if ($user) {
            $PrincipalId = if ($user.value) { $user.value[0].id } else { $user.id }
        } else {
            Write-Warning "Get-O365AzureElevatedRoleAssignments - User '$UserPrincipalName' not found"
            return
        }
    }
    if (-not $PrincipalId) {
        $me = Invoke-O365Admin -Uri 'https://graph.microsoft.com/v1.0/me?$select=id' -Headers $Headers
        $PrincipalId = $me.id
    }
    $Uri = 'https://management.azure.com/providers/Microsoft.Authorization/roleAssignments'
    $QueryParameter = @{ 'api-version' = $ApiVersion; '$filter' = "principalId eq '$PrincipalId'" }
    $Assignments = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -QueryParameter $QueryParameter
    if (-not $Assignments) { return }
    if (-not $Assignments.value) {
        Write-Verbose 'Get-O365AzureElevatedRoleAssignments - No assignments returned.'
        return
    }
    $Assignments.value | Where-Object { $_.properties.scope -eq '/' } | ForEach-Object {
        [pscustomobject]@{
            Id               = $_.id
            Scope            = $_.properties.scope
            RoleDefinitionId = $_.properties.roleDefinitionId
            PrincipalId      = $_.properties.principalId
            PrincipalType    = $_.properties.principalType
            CreatedOn        = $_.properties.createdOn
            UpdatedOn        = $_.properties.updatedOn
        }
    }
}
