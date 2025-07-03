function Remove-O365AzureElevatedAccess {
    <#
    .SYNOPSIS
    Removes the elevated access assignment for the specified principal. When no
    principal is specified the current user is used.

    .DESCRIPTION
    Finds and deletes the User Access Administrator role assignment created by elevation.

    .PARAMETER Headers
    Authentication headers obtained from Connect-O365Admin.

    .PARAMETER PrincipalId
    Object ID of the principal whose elevated access should be removed.

    .PARAMETER UserPrincipalName
    User principal name of the principal whose elevated access should be removed.

    .PARAMETER ApiVersion
    API version to use. Defaults to '2022-04-01'.

    .EXAMPLE
    Remove-O365AzureElevatedAccess -Headers $headers -PrincipalId $UserId

    .EXAMPLE
    Remove-O365AzureElevatedAccess -UserPrincipalName 'admin@contoso.com'

    .EXAMPLE
    # Remove elevation for the currently connected user
    Remove-O365AzureElevatedAccess
    #>
    [cmdletbinding(SupportsShouldProcess, DefaultParameterSetName = 'Self')]
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
            Write-Warning "Remove-O365AzureElevatedAccess - User '$UserPrincipalName' not found"
            return
        }
    }
    if (-not $PrincipalId) {
        $me = Invoke-O365Admin -Uri 'https://graph.microsoft.com/v1.0/me?$select=id' -Headers $Headers
        $PrincipalId = $me.id
    }
    $RoleDefUri = 'https://management.azure.com/providers/Microsoft.Authorization/roleDefinitions'
    $RoleDefQuery = @{ 'api-version' = $ApiVersion; '$filter' = "roleName eq 'User Access Administrator'" }
    $RoleDef = Invoke-O365Admin -Uri $RoleDefUri -Headers $Headers -QueryParameter $RoleDefQuery
    if (-not $RoleDef) { return }
    $RoleDefinitionId = $RoleDef.value[0].name

    $AssignUri = 'https://management.azure.com/providers/Microsoft.Authorization/roleAssignments'
    $AssignQuery = @{ 'api-version' = $ApiVersion; '$filter' = "principalId eq '$PrincipalId'" }
    $Assignments = Invoke-O365Admin -Uri $AssignUri -Headers $Headers -QueryParameter $AssignQuery

    $Assignment = $Assignments.value | Where-Object { $_.properties.scope -eq '/' -and $_.properties.roleDefinitionId -like "*/$RoleDefinitionId" }
    if ($Assignment) {
        $AssignmentId = ($Assignment.id -split '/')[-1]
        $DeleteUri = "https://management.azure.com/providers/Microsoft.Authorization/roleAssignments/$AssignmentId"
        $DelQuery = @{ 'api-version' = $ApiVersion }
        if ($PSCmdlet.ShouldProcess($AssignmentId, 'Remove elevated access')) {
            Invoke-O365Admin -Uri $DeleteUri -Headers $Headers -Method DELETE -QueryParameter $DelQuery
        }
    } else {
        Write-Verbose 'Elevated role assignment not found.'
    }
}
