function Set-O365OrgAccountLinking {
    <#
    .SYNOPSIS
    Users who connect their Azure AD account with their MSA account can earn rewards points when they search on Bing.
    This cmdlet allows to enable/disable this feature.

    .DESCRIPTION
    Users who connect their Azure AD account with their MSA account can earn rewards points when they search on Bing.
    This cmdlet allows to enable/disable this feature.

    .PARAMETER Headers
    The headers to use for the request

    .PARAMETER EnableExtension
    Enable or disable the feature

    .EXAMPLE
    Set-O365OrgAccountLinking

    .NOTES
    General notes
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][bool] $EnableExtension
    )
    $Uri = "https://admin.microsoft.com/fd/bfb/api/v3/office/switch/feature"

    if ($EnableExtension -eq $false) {
        $Body = @{
            features = @('AccountLinking')
        }
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method DELETE -Body $Body
    } elseif ($EnableExtension -eq $true) {
        $Body = @{
            features = @('AccountLinking')
        }
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body
    }
}