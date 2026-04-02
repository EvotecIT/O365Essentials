function Get-O365OrgMicrosoftEdgeSiteLists {
    <#
    .SYNOPSIS
    Retrieves Microsoft Edge enterprise site list data for the organization.

    .DESCRIPTION
    Reads the Microsoft Edge site list and notification payloads used by the
    Microsoft 365 admin center.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which Microsoft Edge site list payload to return.

    .EXAMPLE
    Get-O365OrgMicrosoftEdgeSiteLists

    .EXAMPLE
    Get-O365OrgMicrosoftEdgeSiteLists -Name Notifications
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('All', 'Notifications', 'SiteLists')][string] $Name = 'All'
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

    function Get-EdgeSiteListSafeResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            $Result = & $ScriptBlock
            if ($null -eq $Result) {
                if ($ResultName -eq 'Notifications') {
                    New-O365UnavailableResult -Name $ResultName -Area 'Microsoft Edge site lists section' -Description 'The Microsoft Edge notifications feed did not return data. This route is optional in some healthy tenants.' -SuggestedAction 'Validate only if Microsoft Edge site list notifications are expected in this tenant.' -IsOptional $true
                } else {
                    New-O365UnavailableResult -Name $ResultName -Area 'Microsoft Edge site lists section' -Description 'The Microsoft Edge site lists section did not return a usable payload.'
                }
            } else {
                $Result
            }
        } catch {
            if ($ResultName -eq 'Notifications') {
                New-O365UnavailableResult -Name $ResultName -Area 'Microsoft Edge site lists section' -Description 'The Microsoft Edge notifications feed did not return data. This route is optional in some healthy tenants.' -SuggestedAction 'Validate only if Microsoft Edge site list notifications are expected in this tenant.' -ErrorMessage $_.Exception.Message -IsOptional $true
            } else {
                New-O365UnavailableResult -Name $ResultName -Area 'Microsoft Edge site lists section' -Description 'The Microsoft Edge site lists section did not return a usable payload.' -ErrorMessage $_.Exception.Message
            }
        }
    }

    if ($Name -eq 'All') {
        [PSCustomObject] @{
            SiteLists     = Get-O365OrgMicrosoftEdgeSiteLists -Headers $Headers -Name SiteLists
            Notifications = Get-O365OrgMicrosoftEdgeSiteLists -Headers $Headers -Name Notifications
        }
        return
    }

    $Uri = switch ($Name) {
        'SiteLists' { 'https://admin.cloud.microsoft/fd/edgeenterprisesitemanagement/api/v2/emiesitelists' }
        'Notifications' { 'https://admin.cloud.microsoft/fd/edgeenterprisesitemanagement/api/v2/notifications' }
    }

    Get-EdgeSiteListSafeResult -ResultName $Name -ScriptBlock { Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders -UsePortalSession:$UsePortalSession -QuietOnError }
}
