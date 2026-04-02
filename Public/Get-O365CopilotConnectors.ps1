function Get-O365CopilotConnectors {
    <#
    .SYNOPSIS
    Retrieves Copilot Connectors data from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal Copilot Connectors payloads used by the connector gallery and
    your-connections experience in the Microsoft 365 admin center.

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
        Invoke-O365Admin @Splat
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
                New-O365UnavailableResult -Name $ResultName -Area 'Copilot connectors section' -Description 'The Copilot connectors section did not return a usable payload.'
            } else {
                $Result
            }
        } catch {
            New-O365UnavailableResult -Name $ResultName -Area 'Copilot connectors section' -Description 'The Copilot connectors section did not return a usable payload.' -ErrorMessage $_.Exception.Message
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
            Get-CopilotConnectorSafeResult -ResultName 'Connections' -ScriptBlock { Get-CopilotConnectorLeaf -Uri 'https://admin.cloud.microsoft/fd/mssearchconnectors/v1.0/admin/connections?useRpcOverRest=true' }
            return
        }
        'AdminUxOptions' {
            Get-CopilotConnectorSafeResult -ResultName 'AdminUxOptions' -ScriptBlock { Get-CopilotConnectorLeaf -Uri 'https://admin.cloud.microsoft/fd/mssearchconnectors/v1.0/admin/AdminUxOptions' }
            return
        }
        'GallerySettings' {
            Get-CopilotConnectorSafeResult -ResultName 'GallerySettings' -ScriptBlock { Get-CopilotConnectorLeaf -Uri "https://admin.microsoft.com/fd/ssms/api/v1.0/'MSS'/Collection('VT')/Settings(Path='',LogicalId='all')" }
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
