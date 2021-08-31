function Get-O365AzureADRolesMember {
    [cmdletBinding(DefaultParameterSetName = 'Role')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Role')][Array] $RoleName,

        [Parameter(ParameterSetName = 'Filter')][string] $Filter,

        [Parameter(ParameterSetName = 'Role')]
        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'All')]
        [string[]] $Property,

        [Parameter(ParameterSetName = 'Role')]
        [Parameter(ParameterSetName = 'Filter')]
        [Parameter(ParameterSetName = 'All')]
        [string] $OrderBy,

        [Parameter(ParameterSetName = 'All')][switch] $All
    )
    $Uri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments"
    $QueryParameter = @{
        '$Select'  = $Property -join ','
        '$orderby' = $OrderBy
    }

    $RolesList = [ordered] @{}
    if ($RoleName -or $All) {
        # in case user wanted all roles, we get it to him
        if ($All) {
            # we either use cache, or we ask for it
            if (-not $Script:AzureADRoles) {
                $RoleName = (Get-O365AzureADRoles).displayName
            } else {
                $RoleName = $Script:AzureADRoles.displayName
            }
        }
        # We want to get one or more roles at the same time
        foreach ($Role in $RoleName) {
            $RoleID = $null
            # We find the ID based on the cache or we ask Graph API to provide the list the first time
            if ($Script:AzureADRolesListReverse) {
                $TranslatedRole = $Script:AzureADRolesListReverse[$Role]
            } else {
                $null = Get-O365AzureADRoles
                $TranslatedRole = $Script:AzureADRolesListReverse[$Role]
            }
            if ($TranslatedRole) {
                # Once we have ID we query graph API
                $RoleID = $TranslatedRole.id
                $QueryParameter['$filter'] = "roleDefinitionId eq '$RoleID'"
            } else {
                Write-Warning -Message "Get-O365AzureADRolesMember - Couldn't gather roles because the ID translation didn't work for $Role"
                continue
            }
            Remove-EmptyValue -Hashtable $QueryParameter
            # We query graph API
            Write-Verbose -Message "Get-O365AzureADRolesMember - requesting role $Role ($RoleID)"
            $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter -Method GET
            # if we asked for just one role we return the results directly
            if ($RoleName.Count -eq 1) {
                Write-Verbose -Message "Get-O365AzureADRolesMember - requesting users for $Role ($RoleID)"
                foreach ($User in $Output) {
                    Get-O365PrivateUserOrSPN -PrincipalID $User.principalId
                }
            } else {
                # if we asked for more than one role we add the results to the list
                Write-Verbose -Message "Get-O365AzureADRolesMember - requesting users for $Role ($RoleID)"
                $RolesList[$Role] = foreach ($User in $Output) {
                    Get-O365PrivateUserOrSPN -PrincipalID $User.principalId
                }
            }
        }
        if ($RoleName.Count -gt 1) {
            # if we asked for more than one role we return the list
            $RolesList
        }
    } elseif ($Filter) {
        $QueryParameter['$filter'] = $Filter
        Remove-EmptyValue -Hashtable $QueryParameter
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter -Method GET
        foreach ($User in $Output) {
            Get-O365PrivateUserOrSPN -PrincipalID $User.principalId
        }
    }


}

$Script:AzureRolesScriptBlock = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    #Convert-AzureRole -All | Where-Object { $_ -like "*$wordToComplete*" }
    if (-not $Script:AzureADRoles) {
        $AzureRoles = Get-O365AzureADRoles
    } else {
        $AzureRoles = $Script:AzureADRoles
    }
    ($AzureRoles | Where-Object { $_.displayName -like "*$wordToComplete*" }).displayName
}

Register-ArgumentCompleter -CommandName Get-O365AzureADRolesMember -ParameterName RoleName -ScriptBlock $Script:AzureRolesScriptBlock

<#
    https://graph.microsoft.com/beta/roleManagement/directory/roleAssignments&$filter=roleDefinitionId eq ‘<object-id-or-template-id-of-role-definition>’
    #>

#https://graph.microsoft.com/beta/roleManagement/directory/roleAssignments&$filter=roleDefinitionId eq ‘<object-id-or-template-id-of-role-definition>’


#$Uri = 'https://main.iam.ad.ext.azure.com/api/Roles/User/e6a8f1cf-0874-4323-a12f-2bf51bb6dfdd/RoleAssignments?scope=undefined'

<#
GET https://graph.microsoft.com/beta/rolemanagement/directory/roleAssignments?$filter=principalId eq '55c07278-7109-4a46-ae60-4b644bc83a31'


GET https://graph.microsoft.com/beta/groups?$filter=displayName+eq+'Contoso_Helpdesk_Administrator'

GET https://graph.microsoft.com/beta/roleManagement/directory/roleAssignments?$filter=principalId eq
#>