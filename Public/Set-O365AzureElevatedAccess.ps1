function Set-O365AzureElevatedAccess {
    <#
    .SYNOPSIS
    Elevates the current user's permissions to User Access Administrator or
    grants another principal the same role at root scope.

    .DESCRIPTION
    Sends a request to the Azure management endpoint to grant User Access
    Administrator role at the root scope. When a principal is specified the
    function will instead create a role assignment for that user.

    .PARAMETER Headers
    Authentication headers obtained from Connect-O365Admin.

    .PARAMETER ApiVersion
    API version to use for self elevation. Defaults to '2016-07-01'.

    .PARAMETER RoleApiVersion
    API version for role assignment creation. Defaults to '2022-04-01'.

    .PARAMETER PrincipalId
    Object ID of the principal to elevate.

    .PARAMETER UserPrincipalName
    User principal name of the principal to elevate.

    .EXAMPLE
    Set-O365AzureElevatedAccess -Headers $headers

    .EXAMPLE
    Set-O365AzureElevatedAccess -UserPrincipalName 'admin@contoso.com'
    #>
    [cmdletbinding(SupportsShouldProcess, DefaultParameterSetName = 'Self')]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(ParameterSetName='Id')][string] $PrincipalId,
        [parameter(ParameterSetName='UPN')][string] $UserPrincipalName,
        [string] $ApiVersion = '2016-07-01',
        [string] $RoleApiVersion = '2022-04-01'
    )
    if ($UserPrincipalName) {
        $user = Get-O365User -Headers $Headers -UserPrincipalName $UserPrincipalName -Property id -WarningAction SilentlyContinue
        if ($user) {
            $PrincipalId = if ($user.value) { $user.value[0].id } else { $user.id }
        } else {
            Write-Warning "Set-O365AzureElevatedAccess - User '$UserPrincipalName' not found"
            return
        }
    }

    if ($PrincipalId) {
        $RoleDefUri = 'https://management.azure.com/providers/Microsoft.Authorization/roleDefinitions'
        $RoleDefQuery = @{ 'api-version' = $RoleApiVersion; '$filter' = "roleName eq 'User Access Administrator'" }
        $RoleDef = Invoke-O365Admin -Uri $RoleDefUri -Headers $Headers -QueryParameter $RoleDefQuery
        if (-not $RoleDef) { return }
        $RoleDefinitionId = if ($RoleDef.value) { $RoleDef.value[0].id } else { $RoleDef.id }
        $AssignmentId = [guid]::NewGuid()
        $AssignUri = "https://management.azure.com/providers/Microsoft.Authorization/roleAssignments/$AssignmentId"
        $AssignQuery = @{ 'api-version' = $RoleApiVersion }
        $Body = @{ properties = @{ principalId = $PrincipalId; roleDefinitionId = $RoleDefinitionId; scope = '/' } } | ConvertTo-Json -Depth 5
        if ($PSCmdlet.ShouldProcess($PrincipalId, 'Elevate access for principal')) {
            Invoke-O365Admin -Uri $AssignUri -Headers $Headers -Method PUT -Body $Body -QueryParameter $AssignQuery
        }
    } else {
        $Uri = 'https://management.azure.com/providers/Microsoft.Authorization/elevateAccess'
        $QueryParameter = @{ 'api-version' = $ApiVersion }
        if ($PSCmdlet.ShouldProcess($Uri, 'Elevate access')) {
            Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -QueryParameter $QueryParameter
        }
    }
}
