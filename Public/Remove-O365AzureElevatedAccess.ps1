function Remove-O365AzureElevatedAccess {
    <#
    .SYNOPSIS
    Removes the elevated access assignment for the specified principal.

    .DESCRIPTION
    Finds and deletes the User Access Administrator role assignment created by elevation.

    .PARAMETER Headers
    Authentication headers obtained from Connect-O365Admin.

    .PARAMETER PrincipalId
    Object ID of the principal whose elevated access should be removed.

    .PARAMETER ApiVersion
    API version to use. Defaults to '2022-04-01'.

    .EXAMPLE
    Remove-O365AzureElevatedAccess -Headers $headers -PrincipalId $UserId
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][string] $PrincipalId,
        [string] $ApiVersion = '2022-04-01'
    )
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
