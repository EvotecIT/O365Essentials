function Get-O365OrgAccountLinking {
    <#
    .SYNOPSIS
    Users who connect their Azure AD account with their MSA account can earn rewards points when they search on Bing. User searches are never shared.

    .DESCRIPTION
    Users who connect their Azure AD account with their MSA account can earn rewards points when they search on Bing. User searches are never shared.

    .PARAMETER Headers
    The headers to use for the request

    .EXAMPLE
    Get-O365OrgAccountLinking

    .NOTES
    General notes
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/fd/bfb/api/v3/office/switch/feature"
    $OutputSettings = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST
    if ($OutputSettings) {
        [PSCustomObject] @{
            AccountLinking = if ($OutputSettings.result -contains 'AccountLinking') { $true } else { $false }
        }
    }
}