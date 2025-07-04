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
    $Headers = Connect-O365Admin -Headers $Headers
    if (-not $Headers.HeadersAzure) {
        Write-Warning 'Set-O365AzureElevatedAccess - Azure token not available. Ensure Connect-O365Admin has permission to access https://management.azure.com.'
        return
    }
    if ($UserPrincipalName) {
        $user = Get-O365User -Headers $Headers -UserPrincipalName $UserPrincipalName -Property id -WarningAction SilentlyContinue
        if ($user) {
            $userObj = if ($user.PSObject.Properties['value']) { $user.value[0] } elseif ($user -is [array]) { $user[0] } else { $user }
            $PrincipalId = $userObj.id
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
        $roleItems = if ($RoleDef.PSObject.Properties['value']) { $RoleDef.value } elseif ($RoleDef -is [array]) { $RoleDef } else { @($RoleDef) }
        $RoleDefinitionId = if ($roleItems.Count -gt 0) { if ($roleItems[0].id) { $roleItems[0].id } else { $roleItems[0].name } } else { $null }
        if (-not $RoleDefinitionId) {
            Write-Verbose 'Set-O365AzureElevatedAccess - Role definition not found.'
            return
        }
        $AssignmentId = [guid]::NewGuid()
        $AssignUri = "https://management.azure.com/providers/Microsoft.Authorization/roleAssignments/$AssignmentId"
        $AssignQuery = @{ 'api-version' = $RoleApiVersion }
        $Body = @{ properties = @{ principalId = $PrincipalId; roleDefinitionId = $RoleDefinitionId; scope = '/' } } | ConvertTo-Json -Depth 5
        if ($PSCmdlet.ShouldProcess($PrincipalId, 'Elevate access for principal')) {
            $result = Invoke-O365Admin -Uri $AssignUri -Headers $Headers -Method PUT -Body $Body -QueryParameter $AssignQuery
            if ($result) {
                Write-Verbose "Set-O365AzureElevatedAccess - Created assignment $AssignmentId"
            }
        }
    } else {
        $Uri = 'https://management.azure.com/providers/Microsoft.Authorization/elevateAccess'
        $QueryParameter = @{ 'api-version' = $ApiVersion }
        if ($PSCmdlet.ShouldProcess($Uri, 'Elevate access')) {
            $result = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -QueryParameter $QueryParameter
            if (-not $result) {
                Write-Verbose 'Set-O365AzureElevatedAccess - Elevation request submitted'
            }
        }
    }
}
