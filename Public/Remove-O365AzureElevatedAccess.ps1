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
    $Headers = Connect-O365Admin -Headers $Headers
    if (-not $Headers.HeadersAzure) {
        Write-Warning 'Remove-O365AzureElevatedAccess - Azure token not available. Ensure Connect-O365Admin has permission to access https://management.azure.com.'
        return
    }
    if ($UserPrincipalName) {
        $user = Get-O365User -Headers $Headers -UserPrincipalName $UserPrincipalName -Property id -WarningAction SilentlyContinue
        if ($user) {
            $userObj = if ($user.PSObject.Properties['value']) { $user.value[0] } elseif ($user -is [array]) { $user[0] } else { $user }
            $PrincipalId = $userObj.id
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
    $roleItems = if ($RoleDef.PSObject.Properties['value']) { $RoleDef.value } elseif ($RoleDef -is [array]) { $RoleDef } else { @($RoleDef) }
    if (-not $roleItems -or $roleItems.Count -eq 0) {
        Write-Verbose 'Remove-O365AzureElevatedAccess - Role definition not found.'
        return
    }
    $RoleDefinitionId = if ($roleItems[0].name) { $roleItems[0].name } else { $roleItems[0].id }

    $AssignUri = 'https://management.azure.com/providers/Microsoft.Authorization/roleAssignments'
    $AssignQuery = @{ 'api-version' = $ApiVersion; '$filter' = "principalId eq '$PrincipalId'" }
    $Assignments = Invoke-O365Admin -Uri $AssignUri -Headers $Headers -QueryParameter $AssignQuery
    $items = if ($Assignments.PSObject.Properties['value']) { $Assignments.value } elseif ($Assignments -is [array]) { $Assignments } else { @($Assignments) }

    $Assignment = $items | Where-Object { $_.properties.scope -eq '/' -and $_.properties.roleDefinitionId -like "*/$RoleDefinitionId" }
    if ($Assignment) {
        $AssignmentId = ($Assignment.id -split '/')[-1]
        $DeleteUri = "https://management.azure.com/providers/Microsoft.Authorization/roleAssignments/$AssignmentId"
        $DelQuery = @{ 'api-version' = $ApiVersion }
        if ($PSCmdlet.ShouldProcess($AssignmentId, 'Remove elevated access')) {
            $result = Invoke-O365Admin -Uri $DeleteUri -Headers $Headers -Method DELETE -QueryParameter $DelQuery
            if ($result) {
                Write-Verbose "Remove-O365AzureElevatedAccess - Removed assignment $AssignmentId"
            }
        }
    } else {
        Write-Verbose 'Elevated role assignment not found.'
    }
}
