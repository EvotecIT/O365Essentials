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

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context CopilotConnectors -PortalHost 'https://admin.cloud.microsoft' -AjaxSessionKey $Headers.AjaxSessionKey -PortalRouteKey $Headers.PortalRouteKey
    $HasPortalSessionContext = $false
    if ($Headers) {
        if ($Headers.Contains('AjaxSessionKey') -and -not [string]::IsNullOrWhiteSpace($Headers['AjaxSessionKey'])) {
            $HasPortalSessionContext = $true
        }
        elseif ($Headers.Contains('PortalWebSession') -and $null -ne $Headers['PortalWebSession']) {
            $HasPortalSessionContext = $true
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
            Invoke-O365SectionSafeResult -Section CopilotConnector -ResultName 'Summary' -ScriptBlock { Get-CopilotConnectorLeaf -Uri 'https://admin.cloud.microsoft/admin/api/searchadminapi/UDTConnectorsSummary' }
            return
        }
        'Statistics' {
            Invoke-O365SectionSafeResult -Section CopilotConnector -ResultName 'Statistics' -ScriptBlock { Get-CopilotConnectorLeaf -Uri 'https://admin.cloud.microsoft/fd/mssearchconnectors/v1.0/admin/connections/getStatistics' }
            return
        }
        'Connections' {
            Invoke-O365SectionSafeResult -Section CopilotConnector -ResultName 'Connections' -ScriptBlock { Get-CopilotConnectorLeaf -Uri 'https://admin.cloud.microsoft/fd/mssearchconnectors/v1.0/admin/connections/v2?filterActive=false&useCachedRead=true&includeFederatedConnections=true' }
            return
        }
        'AdminUxOptions' {
            Invoke-O365SectionSafeResult -Section CopilotConnector -ResultName 'AdminUxOptions' -ScriptBlock { Get-CopilotConnectorLeaf -Uri 'https://admin.cloud.microsoft/fd/mssearchconnectors/v1.0/admin/AdminUxOptionsV2/Connectors?query=Connectors' }
            return
        }
        'GallerySettings' {
            $GalleryHeaders = [ordered] @{}
            foreach ($Key in $AdditionalHeaders.Keys) {
                $GalleryHeaders[$Key] = $AdditionalHeaders[$Key]
            }
            if ($Headers -and $Headers.Contains('Tenant') -and -not [string]::IsNullOrWhiteSpace($Headers['Tenant'])) {
                $GalleryHeaders['x-anchormailbox'] = "APP:TenantSetting_AC9A8876-0461-47EA-9d4C-FE8D02AEF7D5@$($Headers['Tenant'])"
            }
            elseif ($Headers -and $Headers.Contains('TenantId') -and -not [string]::IsNullOrWhiteSpace($Headers['TenantId'])) {
                $GalleryHeaders['x-anchormailbox'] = "APP:TenantSetting_AC9A8876-0461-47EA-9d4C-FE8D02AEF7D5@$($Headers['TenantId'])"
            }
            Invoke-O365SectionSafeResult -Section CopilotConnector -ResultName 'GallerySettings' -ScriptBlock { Get-CopilotConnectorLeaf -Uri "https://admin.cloud.microsoft/fd/ssms/api/v1.0/'FSS'/Collection('Staging')/Settings/?`$filter=Path%20eq%20'%3A'" -AdditionalLeafHeaders $GalleryHeaders }
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
