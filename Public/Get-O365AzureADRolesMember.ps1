function Get-O365AzureADRolesMember {
    <#
        .SYNOPSIS
        Retrieves Azure AD roles members based on specified role names or filters.
        .DESCRIPTION
        This function retrieves Azure AD roles members based on specified role names or filters. It allows querying for one or more roles at the same time and provides the flexibility to filter the results based on specific criteria.
        .PARAMETER RoleName
        Specifies the name of the role(s) to retrieve members for.
        .PARAMETER Filter
        Specifies the filter criteria to apply when retrieving role members.
        .PARAMETER Property
        Specifies the properties to include in the results.
        .PARAMETER OrderBy
        Specifies the order in which the results should be sorted.
        .PARAMETER All
        Indicates whether all roles should be retrieved.
        .EXAMPLE
        Get-O365AzureADRolesMember -RoleName "Role1", "Role2" -Property "Property1", "Property2" -OrderBy "Property1" -All
        Retrieves members for specified roles with specific properties and sorting order.
        .EXAMPLE
        Get-O365AzureADRolesMember -Filter "FilterCriteria"
        Retrieves members based on the specified filter criteria.
    #>
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

<#
Invoke-WebRequest -Uri "https://api.azrbac.mspim.azure.com/api/v2/privilegedAccess/aadroles/roleAssignments?`$expand=linkedEligibleRoleAssignment,subject,scopedResource,roleDefinition(`$expand=resource)&`$count=true&`$filter=(roleDefinition/resource/id%20eq%20%27ceb371f6-8745-4876-a040-69f2d10a9d1a%27)+and+(roleDefinition/id%20eq%20%275d6b6bb7-de71-4623-b4af-96380a352509%27)+and+(assignmentState%20eq%20%27Eligible%27)&`$orderby=roleDefinition/displayName&`$skip=0&`$top=10" -Headers @{
"x-ms-client-session-id"="3049c4c42d944f68bb7423154f7a1da5"
  "Accept-Language"="en"
  "Authorization"="Bearer ."
  "x-ms-effective-locale"="en.en-us"
  "Accept"="application/json, text/javascript, */*; q=0.01"
  #"Referer"=""
  "x-ms-client-request-id"="b0a543fc-ca4c-4ac6-aef6-5ceb09ad9003"
  "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84"
}
#>
