function Get-O365SearchIntelligenceBingExtension {
    <#
    .SYNOPSIS
    Retrieves Bing search intelligence extensions for Office 365.

    .DESCRIPTION
    This function retrieves Bing search intelligence extensions for Office 365 from the specified API endpoint using the provided headers. It checks if Bing is set as the default search engine and lists the groups for which Bing is enabled as the default search engine.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .EXAMPLE
    Get-O365SearchIntelligenceBingExtension -Headers $headers

    .NOTES
    This function requires a valid set of headers for authentication and authorization to access the Office 365 API.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/fd/bfb/api/v3/office/switch/feature"
    $OutputBing = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST
    if ($OutputBing) {
        [PSCustomObject] @{
            BingDefaultEngine = if ($OutputBing.result -contains 'BingDefault') { $true } else { $false }
            #BingDefaultGroup = if ($OutputBing.result[1] -eq 'BingDefaultGroupWise') { $true } else { $false }
            BingDefaultGroups = if ($OutputBing.bingDefaultsEnabledGroups) { $OutputBing.bingDefaultsEnabledGroups } else { $null }
        }
    }
}