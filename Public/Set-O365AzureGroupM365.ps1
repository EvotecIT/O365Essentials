function Set-O365AzureGroupM365 {
    <#
    .SYNOPSIS
    Enables or Disables Microsoft 365 Groups - "Users can create Microsoft 365 groups in Azure portals, API or PowerShell"

    .DESCRIPTION
    Enables or Disables Microsoft 365 Groups - "Users can create Microsoft 365 groups in Azure portals, API or PowerShell"

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

    .PARAMETER AllowedToCreateM365Groups
    Enables or disables "Users can create Microsoft 365 groups in Azure portals, API or PowerShell"

    .EXAMPLE
    Set-O365AzureGroupM365 -Verbose -AllowedToCreateM365Groups $true -WhatIf

    .NOTES
    https://portal.azure.com/#blade/Microsoft_AAD_IAM/GroupsManagementMenuBlade/General
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][bool] $AllowedToCreateM365Groups
    )
    $CurrentSettings = Get-O365AzureGroupNamingPolicy -NoTranslation -Headers $Headers
    if ($CurrentSettings.id) {
        $Uri = "https://graph.microsoft.com/beta/settings/$($CurrentSettings.id)"
        [Array] $Values = foreach ($Policy in $CurrentSettings.values) {
            if ($Policy.Name -eq 'EnableGroupCreation') {
                [PSCustomObject] @{
                    name  = 'EnableGroupCreation'
                    value = $AllowedToCreateM365Groups.ToString()
                }
            } else {
                $Policy
            }
        }
        $Body = @{
            values = $Values
        }
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PATCH -Body $Body
    }
}