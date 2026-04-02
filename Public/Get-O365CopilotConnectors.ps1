function Get-O365CopilotConnectors {
    <#
    .SYNOPSIS
    Retrieves Copilot Connectors data from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal Copilot Connectors payloads used by the connector gallery and
    your-connections experience in the Microsoft 365 admin center.

    The cmdlet is token-first, but when the current connection carries hidden
    admin.cloud.microsoft portal state it automatically replays portal-sensitive routes
    through that session. If a usable payload still is not available, the cmdlet returns
    a structured unavailable result instead of raw 440 warning noise.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which connectors payload to return.

    .EXAMPLE
    Get-O365CopilotConnectors

    .EXAMPLE
    Get-O365CopilotConnectors -Name YourConnections
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('AdminUxOptions', 'All', 'Connections', 'Gallery', 'GallerySettings', 'Statistics', 'Summary', 'YourConnections')][string] $Name = 'All'
    )

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context MicrosoftSearch -PortalHost 'https://admin.cloud.microsoft' -AjaxSessionKey $Headers.AjaxSessionKey -PortalRouteKey $Headers.PortalRouteKey
    $HasPortalSessionContext = $false
    if ($Headers) {
        if ($Headers.Contains('AjaxSessionKey') -and -not [string]::IsNullOrWhiteSpace($Headers['AjaxSessionKey'])) {
            $HasPortalSessionContext = $true
        } elseif ($Headers.Contains('PortalWebSession') -and $null -ne $Headers['PortalWebSession']) {
            $HasPortalSessionContext = $true
        }
    }

    function Get-CopilotConnectorLeaf {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $Uri
        )

        $Splat = @{
            Uri               = $Uri
            Headers           = $Headers
            Method            = 'GET'
            AdditionalHeaders = $AdditionalHeaders
        }
        if ($HasPortalSessionContext -and $Uri -like 'https://admin.cloud.microsoft/*') {
            $Splat['UsePortalSession'] = $true
        }
        $Splat['QuietOnError'] = $true
        Invoke-O365Admin @Splat
    }

    function New-CopilotConnectorUnavailableResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [string] $ErrorMessage
        )

        $Reason = 'TenantSpecific'
        $Description = 'The Copilot connectors section did not return a usable payload.'
        $SuggestedAction = 'Verify the tenant has Copilot connectors features enabled, the signed-in account has the required admin role, and the route is available in the current portal experience.'

        if (-not $HasPortalSessionContext -or $ErrorMessage -match '\b440\b') {
            $Reason = 'PortalSessionRequired'
            $Description = 'The Copilot connectors section appears to require an authenticated admin.cloud.microsoft portal session with AjaxSessionKey or portal cookies in addition to bearer-token auth.'
            $SuggestedAction = 'Replay the request through a validated admin.cloud.microsoft portal session or supply portal session state before retrying this Copilot surface.'
        }

        New-O365UnavailableResult -Name $ResultName -Area 'Copilot connectors section' -Description $Description -Reason $Reason -ErrorMessage $ErrorMessage -SuggestedAction $SuggestedAction
    }

    function Get-CopilotConnectorSafeResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            $Result = & $ScriptBlock
            if ($null -eq $Result) {
                New-CopilotConnectorUnavailableResult -ResultName $ResultName
            } else {
                $Result
            }
        } catch {
            New-CopilotConnectorUnavailableResult -ResultName $ResultName -ErrorMessage $_.Exception.Message
        }
    }

    switch ($Name) {
        'All' {
            [PSCustomObject] @{
                YourConnections = Get-O365CopilotConnectors -Headers $Headers -Name YourConnections
                Gallery         = Get-O365CopilotConnectors -Headers $Headers -Name Gallery
            }
            return
        }
        'Summary' {
            Get-CopilotConnectorSafeResult -ResultName 'Summary' -ScriptBlock { Get-CopilotConnectorLeaf -Uri 'https://admin.cloud.microsoft/admin/api/searchadminapi/UDTConnectorsSummary' }
            return
        }
        'Statistics' {
            Get-CopilotConnectorSafeResult -ResultName 'Statistics' -ScriptBlock { Get-CopilotConnectorLeaf -Uri 'https://admin.cloud.microsoft/fd/mssearchconnectors/v1.0/admin/connections/getStatistics' }
            return
        }
        'Connections' {
            Get-CopilotConnectorSafeResult -ResultName 'Connections' -ScriptBlock { Get-CopilotConnectorLeaf -Uri 'https://admin.cloud.microsoft/fd/mssearchconnectors/v1.0/admin/connections/v2?filterActive=false&useCachedRead=true&includeFederatedConnections=true' }
            return
        }
        'AdminUxOptions' {
            Get-CopilotConnectorSafeResult -ResultName 'AdminUxOptions' -ScriptBlock { Get-CopilotConnectorLeaf -Uri 'https://admin.cloud.microsoft/fd/mssearchconnectors/v1.0/admin/AdminUxOptionsV2/Connectors?query=Connectors' }
            return
        }
        'GallerySettings' {
            Get-CopilotConnectorSafeResult -ResultName 'GallerySettings' -ScriptBlock { Get-CopilotConnectorLeaf -Uri "https://admin.cloud.microsoft/fd/ssms/api/v1.0/'MSS'/Collection('VT')/Settings(Path='',LogicalId='all')" }
            return
        }
        'YourConnections' {
            [PSCustomObject] @{
                Summary     = Get-O365CopilotConnectors -Headers $Headers -Name Summary
                Statistics  = Get-O365CopilotConnectors -Headers $Headers -Name Statistics
                Connections = Get-O365CopilotConnectors -Headers $Headers -Name Connections
            }
            return
        }
        'Gallery' {
            [PSCustomObject] @{
                Summary         = Get-O365CopilotConnectors -Headers $Headers -Name Summary
                Statistics      = Get-O365CopilotConnectors -Headers $Headers -Name Statistics
                AdminUxOptions  = Get-O365CopilotConnectors -Headers $Headers -Name AdminUxOptions
                GallerySettings = Get-O365CopilotConnectors -Headers $Headers -Name GallerySettings
            }
            return
        }
    }
}
