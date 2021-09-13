function Set-O365AzureGroupSecurity {
    <#
    .SYNOPSIS
    Set settings for Security Groups "Users can create security groups in Azure portals, API or PowerShell"

    .DESCRIPTION
    Set settings for Security Groups "Users can create security groups in Azure portals, API or PowerShell"

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

    .PARAMETER AllowedToCreateSecurityGroups
    Enables or Disables - "Users can create security groups in Azure portals, API or PowerShell"

    .EXAMPLE
    Set-O365AzureGroupSecurity -Verbose -AllowedToCreateSecurityGroups $true -WhatIf

    .NOTES
    https://portal.azure.com/#blade/Microsoft_AAD_IAM/GroupsManagementMenuBlade/General
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][bool] $AllowedToCreateSecurityGroups
    )
    # "https://graph.microsoft.com/beta/policies/authorizationPolicy/authorizationPolicy"
    $Uri = "https://graph.microsoft.com/v1.0/policies/authorizationPolicy"

    $Body = @{
        defaultUserRolePermissions = @{
            allowedToCreateSecurityGroups = $AllowedToCreateSecurityGroups
        }
    }
    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PATCH -Body $Body
}