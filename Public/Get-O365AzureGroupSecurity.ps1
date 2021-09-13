function Get-O365AzureGroupSecurity {
    <#
    .SYNOPSIS
    Get settings for Security Groups - "Users can create security groups in Azure portals, API or PowerShell"

    .DESCRIPTION
    Get settings for Security Groups - "Users can create security groups in Azure portals, API or PowerShell"

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

    .PARAMETER NoTranslation
    Provides output without any translation. Mostly required for testing or during internal configuration.

    .EXAMPLE
    Get-O365AzureGroupSecurity -Verbose

    .NOTES
    https://portal.azure.com/#blade/Microsoft_AAD_IAM/GroupsManagementMenuBlade/General
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
    $Uri = 'https://graph.microsoft.com/beta/policies/authorizationPolicy/authorizationPolicy'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method Get


    if ($Output) {
        if ($NoTranslation) {
            $Output
        } else {
            [PSCustomObject] @{
                "AllowedToCreateSecurityGroups" = $Output.defaultUserRolePermissions.allowedToCreateSecurityGroups
            }
        }
    }
}
