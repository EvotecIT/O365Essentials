function Get-O365OrgMicrosoftEdge {
    <#
    .SYNOPSIS
    Retrieves Microsoft Edge admin-center settings for the organization.

    .DESCRIPTION
    Reads the richer Microsoft Edge admin-center payloads for policy, extension,
    device, and site list management.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which Microsoft Edge payload to return.

    .EXAMPLE
    Get-O365OrgMicrosoftEdge

    .EXAMPLE
    Get-O365OrgMicrosoftEdge -Name DeviceCount
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('All', 'ConfigurationPolicies', 'DeviceCount', 'ExtensionFeedback', 'ExtensionPolicies', 'FeatureProfiles', 'SiteLists')][string] $Name = 'All'
    )

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context MicrosoftEdge -PortalHost 'https://admin.cloud.microsoft' -AjaxSessionKey $Headers.AjaxSessionKey -PortalRouteKey $Headers.PortalRouteKey
    $UsePortalSession = $false
    if ($Headers) {
        if ($Headers.Contains('AjaxSessionKey') -and -not [string]::IsNullOrWhiteSpace($Headers['AjaxSessionKey'])) {
            $UsePortalSession = $true
        }
        elseif ($Headers.Contains('PortalWebSession') -and $null -ne $Headers['PortalWebSession']) {
            $UsePortalSession = $true
        }
    }

    if ($Name -eq 'All') {
        [PSCustomObject] @{
            ConfigurationPolicies = Get-O365OrgMicrosoftEdge -Headers $Headers -Name ConfigurationPolicies
            DeviceCount           = Get-O365OrgMicrosoftEdge -Headers $Headers -Name DeviceCount
            FeatureProfiles       = Get-O365OrgMicrosoftEdge -Headers $Headers -Name FeatureProfiles
            ExtensionPolicies     = Get-O365OrgMicrosoftEdge -Headers $Headers -Name ExtensionPolicies
            ExtensionFeedback     = Get-O365OrgMicrosoftEdge -Headers $Headers -Name ExtensionFeedback
            SiteLists             = Get-O365OrgMicrosoftEdge -Headers $Headers -Name SiteLists
        }
        return
    }

    switch ($Name) {
        'DeviceCount' {
            $Result = Get-MicrosoftEdgeSafeResult -ResultName 'DeviceCount' -ScriptBlock {
                Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/fd/MSGraph/v1.0/devices?$count=true&$top=1' -Headers $Headers -Method GET -AdditionalHeaders (Get-MicrosoftEdgeHeaders -ExtraHeaders @{ ConsistencyLevel = 'eventual' }) -UsePortalSession:$UsePortalSession
            }

            if (Test-O365UnavailableResult -InputObject $Result) {
                $Result
            }
            else {
                ConvertTo-MicrosoftEdgeDeviceSummary -DeviceResult $Result
            }
            return
        }
        'ExtensionFeedback' {
            Get-MicrosoftEdgeSafeResult -ResultName 'ExtensionFeedback' -ScriptBlock {
                Invoke-O365Admin -Uri 'https://admin.cloud.microsoft/fd/edgeenterpriseextensionsmanagement/api/extensions/extensionFeedback' -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders -UsePortalSession:$UsePortalSession -QuietOnError
            }
            return
        }
        'SiteLists' {
            Get-O365OrgMicrosoftEdgeSiteLists -Headers $Headers -Name All
            return
        }
    }

    $Uri = switch ($Name) {
        'ConfigurationPolicies' { 'https://admin.cloud.microsoft/fd/OfficePolicyAdmin/v1.0/edge/policies' }
        'ExtensionPolicies' { 'https://admin.cloud.microsoft/fd/edgeenterpriseextensionsmanagement/api/policies' }
        'FeatureProfiles' { 'https://admin.cloud.microsoft/fd/edgeenterpriseextensionsmanagement/api/featureManagement/profiles' }
    }

    Get-MicrosoftEdgeSafeResult -ResultName $Name -ScriptBlock { Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders -UsePortalSession:$UsePortalSession }
}
