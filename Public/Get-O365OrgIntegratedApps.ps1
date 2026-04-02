function Get-O365OrgIntegratedApps {
    <#
    .SYNOPSIS
    Retrieves integrated apps data from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal integrated apps payloads such as app catalog, available apps,
    actionable apps, and recommendations.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which integrated apps payload to return.

    .EXAMPLE
    Get-O365OrgIntegratedApps

    .EXAMPLE
    Get-O365OrgIntegratedApps -Name AppCatalog
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('ActionableApps', 'All', 'AppCatalog', 'AvailableApps', 'PopularAppRecommendations', 'Settings')][string] $Name = 'All'
    )

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context IntegratedApps

    function Get-IntegratedAppsSafeResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            $Result = & $ScriptBlock
            if ($null -eq $Result) {
                New-O365UnavailableResult -Name $ResultName -Area 'Integrated apps section' -Description 'The integrated apps section did not return a usable payload.'
            } else {
                $Result
            }
        } catch {
            New-O365UnavailableResult -Name $ResultName -Area 'Integrated apps section' -Description 'The integrated apps section did not return a usable payload.' -ErrorMessage $_.Exception.Message
        }
    }

    if ($Name -eq 'All') {
        [PSCustomObject] @{
            Settings                  = Get-O365OrgIntegratedApps -Headers $Headers -Name Settings
            AppCatalog                = Get-O365OrgIntegratedApps -Headers $Headers -Name AppCatalog
            AvailableApps             = Get-O365OrgIntegratedApps -Headers $Headers -Name AvailableApps
            ActionableApps            = Get-O365OrgIntegratedApps -Headers $Headers -Name ActionableApps
            PopularAppRecommendations = Get-O365OrgIntegratedApps -Headers $Headers -Name PopularAppRecommendations
        }
        return
    }

    $Uri = switch ($Name) {
        'Settings' { 'https://admin.microsoft.com/fd/addins/api/v2/settings?keys=IsTenantEligibleForEntireOrgEmail,AreFirstPartyAppsAllowed,AreThirdPartyAppsAllowed,AreLOBAppsAllowed,AreMicrosoftCertified3PAppsAllowed,MetaOSCopilotExtensibilitySettings' }
        'AppCatalog' { 'https://admin.microsoft.com/fd/addins/api/apps?workloads=AzureActiveDirectory,WXPO,MetaOS,SharePoint' }
        'AvailableApps' { 'https://admin.microsoft.com/fd/addins/api/availableApps?workloads=MetaOS' }
        'ActionableApps' { 'https://admin.microsoft.com/fd/addins/api/actionableApps?workloads=MetaOS' }
        'PopularAppRecommendations' { 'https://admin.microsoft.com/fd/addins/api/recommendations/appRecommendations?appRecommendationType=PopularApps' }
    }

    Get-IntegratedAppsSafeResult -ResultName $Name -ScriptBlock { Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders }
}
