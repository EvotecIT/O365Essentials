function Get-O365OrgBrandCenter {
    <#
    .SYNOPSIS
    Retrieves Brand Center data from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads the internal Brand Center configuration and site URL payloads used by the
    organization settings experience.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which Brand Center payload to return.

    .EXAMPLE
    Get-O365OrgBrandCenter

    .EXAMPLE
    Get-O365OrgBrandCenter -Name SiteUrl
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('All', 'Configuration', 'SiteUrl')][string] $Name = 'All'
    )

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context BrandCenter

    function Get-BrandCenterSafeResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            $Result = & $ScriptBlock
            if ($null -eq $Result) {
                New-O365UnavailableResult -Name $ResultName -Area 'Brand Center section' -Description 'The Brand Center section did not return a usable payload.'
            } else {
                $Result
            }
        } catch {
            New-O365UnavailableResult -Name $ResultName -Area 'Brand Center section' -Description 'The Brand Center section did not return a usable payload.' -ErrorMessage $_.Exception.Message
        }
    }

    if ($Name -eq 'All') {
        [PSCustomObject] @{
            Configuration = Get-O365OrgBrandCenter -Headers $Headers -Name Configuration
            SiteUrl       = Get-O365OrgBrandCenter -Headers $Headers -Name SiteUrl
        }
        return
    }

    $Uri = switch ($Name) {
        'Configuration' { 'https://admin.microsoft.com/_api/spo.tenant/GetBrandCenterConfiguration' }
        'SiteUrl' { "https://admin.microsoft.com/_api/GroupSiteManager/GetValidSiteUrlFromAlias?alias='BrandGuide'&managedPath='sites'" }
    }

    Get-BrandCenterSafeResult -ResultName $Name -ScriptBlock { Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders }
}
