function Get-O365AzureGroupNamingPolicy {
    <#
    .SYNOPSIS
    Gets the Azure Group naming policy.

    .DESCRIPTION
    Gets the Azure Group naming policy.

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

    .PARAMETER NoTranslation
    Provides output without any translation. Mostly required for testing or during internal configuration.

    .EXAMPLE
    Get-O365AzureGroupNamingPolicy

    .NOTES
    https://portal.azure.com/#blade/Microsoft_AAD_IAM/GroupsManagementMenuBlade/NamingPolicy
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
            if ($Values.Count -gt 1) {
                $Prefix = $Values | Where-Object { $_.Name -eq 'PrefixSuffixNamingRequirement' }
                if ($Prefix.value) {
                    $PrefixSplit = $Prefix.value.split('[GroupName]')
                    [PSCUstomObject] @{
                        Prefix           = $PrefixSplit[0]
                        Suffix           = $PrefixSplit[1]
                        PrefixSuffixFull = $Prefix.value
                    }
                }
            }
        }
    }
}