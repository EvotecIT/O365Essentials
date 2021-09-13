function Set-O365AzureGroupNamingPolicy {
    <#
    .SYNOPSIS
    Sets new prefix/suffix for M365 groups naming policy.

    .DESCRIPTION
    Sets new prefix/suffix for M365 groups naming policy. The Microsoft 365 groups naming policy allows you to add a specific prefix and/or suffix to the group name and alias of any Microsoft 365 group created by users. For example: <Finance> <group> <Seattle>

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

    .PARAMETER Prefix
    Sets or updates the prefix for the group naming policy. One can use words or predefined prefixes.

    .PARAMETER Suffix
    Sets or updates the suffix for the group naming policy. One can use words or predefined suffixes.

    .PARAMETER RemoveNamingConvention
    Removes the prefix and suffix from the group naming policy.

    .EXAMPLE
    Set-O365AzureGroupNamingPolicy -Verbose -Prefix 'O365' -Suffix 'Uops', [Company], 'test' -WhatIf

    .EXAMPLE
    Set-O365AzureGroupNamingPolicy -Verbose -Prefix 'O365' -Suffix '' -WhatIf

    .EXAMPLE
    Set-O365AzureGroupNamingPolicy -Verbose -RemoveNamingConvention -WhatIf

    .NOTES
    https://portal.azure.com/#blade/Microsoft_AAD_IAM/GroupsManagementMenuBlade/NamingPolicy
    #>
    [cmdletbinding(SupportsShouldProcess, DefaultParameterSetName = 'PrefixSuffix')]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(ParameterSetName = 'PrefixSuffix')][string[]] $Prefix,
        [Parameter(ParameterSetName = 'PrefixSuffix')][string[]] $Suffix,
        [Parameter(ParameterSetName = 'Remove')][switch] $RemoveNamingConvention
    )
    $CurrentSettings = Get-O365AzureGroupNamingPolicy -NoTranslation -Headers $Headers
    if ($CurrentSettings.id) {
        $Uri = "https://graph.microsoft.com/beta/settings/$($CurrentSettings.id)"
        [Array] $Values = foreach ($Policy in $CurrentSettings.values) {
            if ($Policy.Name -eq 'PrefixSuffixNamingRequirement') {
                if ($RemoveNamingConvention) {
                    $ExpectedPolicy = ''
                } else {
                    $ExpectedPolicy = ($Prefix -join "") + "[GroupName]" + ($Suffix -join "")
                }
                [PSCustomObject] @{
                    name  = 'PrefixSuffixNamingRequirement'
                    value = $ExpectedPolicy
                }
            } else {
                $Policy
            }
        }
        $Body = @{
            values = $Values
        }
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PATCH -Body $Body
        $Output
    }
}

$Script:ScriptBlockNamingPolicy = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $Static = @(
        '[Department]'
        '[Company]'
        '[Office]'
        '[StateOrProvince]'
        '[CountryOrRegion]'
        '[Title]'
    )

    $Static | Where-Object { $_ -like "*$wordToComplete*" }
}

Register-ArgumentCompleter -CommandName Set-O365AzureGroupNamingPolicy -ParameterName Prefix -ScriptBlock $Script:ScriptBlockNamingPolicy
Register-ArgumentCompleter -CommandName Set-O365AzureGroupNamingPolicy -ParameterName Suffix -ScriptBlock $Script:ScriptBlockNamingPolicy