function Set-O365AzureGroupNamingPolicy {
    [cmdletbinding(SupportsShouldProcess, DefaultParameterSetName = 'PrefixSuffix')]
    param(
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