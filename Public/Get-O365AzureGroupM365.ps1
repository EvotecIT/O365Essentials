function Get-O365AzureGroupM365 {
    <#
    .SYNOPSIS
    Get settings for Microsoft 365 Groups - "Users can create Microsoft 365 groups in Azure portals, API or PowerShell"

    .DESCRIPTION
    Get settings for Microsoft 365 Groups - "Users can create Microsoft 365 groups in Azure portals, API or PowerShell"

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

    .PARAMETER NoTranslation
    Provides output without any translation. Mostly required for testing or during internal configuration.

    .EXAMPLE
    Get-O365AzureGroupM365 -Verbose

    .NOTES
    https://portal.azure.com/#blade/Microsoft_AAD_IAM/GroupsManagementMenuBlade/General
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
    $Uri = 'https://graph.microsoft.com/beta/settings'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method Get
    if ($Output) {
        if ($NoTranslation) {
            $Output | Where-Object { $_.DisplayName -eq "Group.Unified" }
        } else {
            $Values = ($Output | Where-Object { $_.DisplayName -eq "Group.Unified" }).values
            $OutputInformation = [ordered] @{}
            if ($Values.Count -gt 1) {
                foreach ($Value in $Values) {
                    $OutputInformation[$Value.name] = if ($Value.value -eq "true") { $true } elseif ( $Value.value -eq "false") { $false } else { $Value.value }
                }
            }
            [PSCustomObject] $OutputInformation
        }
    }
}