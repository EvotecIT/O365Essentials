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
        }
        elseif ($Headers.Contains('PortalWebSession') -and $null -ne $Headers['PortalWebSession']) {
            $UsePortalSession = $true
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
