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
        } elseif ($Headers.Contains('PortalWebSession') -and $null -ne $Headers['PortalWebSession']) {
            $UsePortalSession = $true
        }
    }

    function Get-MicrosoftEdgeHeaders {
        [cmdletbinding()]
        param(
            [hashtable] $ExtraHeaders
        )

        $HeadersToSend = [ordered] @{}
        foreach ($Key in $AdditionalHeaders.Keys) {
            $HeadersToSend[$Key] = $AdditionalHeaders[$Key]
        }

        if ($ExtraHeaders) {
            foreach ($Key in $ExtraHeaders.Keys) {
                $HeadersToSend[$Key] = $ExtraHeaders[$Key]
            }
        }

        $HeadersToSend
    }

    function Get-MicrosoftEdgeSafeResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            $Result = & $ScriptBlock
            if ($null -eq $Result) {
                if ($ResultName -in @('ConfigurationPolicies', 'ExtensionFeedback')) {
                    Write-Output -NoEnumerate @()
                } else {
                    New-O365UnavailableResult -Name $ResultName -Area 'Microsoft Edge section' -Description 'The Microsoft Edge section did not return a usable payload.'
                }
            } else {
                $Result
            }
        } catch {
            if ($ResultName -eq 'ExtensionFeedback') {
                New-O365UnavailableResult -Name $ResultName -Area 'Microsoft Edge section' -Description 'The Microsoft Edge extension feedback feed did not return data in the current tenant.' -SuggestedAction 'Validate only if extension feedback is expected for this tenant.' -ErrorMessage $_.Exception.Message -IsOptional $true
            } else {
                New-O365UnavailableResult -Name $ResultName -Area 'Microsoft Edge section' -Description 'The Microsoft Edge section did not return a usable payload.' -ErrorMessage $_.Exception.Message
            }
        }
    }

    function ConvertTo-MicrosoftEdgeDeviceSummary {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)] $DeviceResult
        )

        [PSCustomObject] @{
            Count       = $DeviceResult.'@odata.count'
            Sample      = @($DeviceResult.value)
            RawSettings = $DeviceResult
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
            } else {
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
