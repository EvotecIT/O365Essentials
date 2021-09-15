function Get-O365SearchIntelligenceBingExtension {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/fd/bfb/api/v3/office/switch/feature"
    $OutputBing = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST
    if ($OutputBing) {
        [PSCustomObject] @{
            BingDefaultEngine = if ($OutputBing.result[0] -eq 'BingDefault') { $true } else { $false }
            #BingDefaultGroup = if ($OutputBing.result[1] -eq 'BingDefaultGroupWise') { $true } else { $false }
            BingDefaultGroups = if ($OutputBing.bingDefaultsEnabledGroups) { $OutputBing.bingDefaultsEnabledGroups } else { $null }
        }
    }
}