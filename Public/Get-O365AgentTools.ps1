function Get-O365AgentTools {
    <#
    .SYNOPSIS
    Retrieves Agents tools data from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal Agents tools payloads, currently focused on MCP server inventory.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which Agents tools payload to return.

    .EXAMPLE
    Get-O365AgentTools
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('All', 'McpServers')][string] $Name = 'All'
    )

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context Agents -PortalHost 'https://admin.cloud.microsoft' -AjaxSessionKey $Headers.AjaxSessionKey -PortalRouteKey $Headers.PortalRouteKey
    $UsePortalSession = $false
    if ($Headers) {
        if ($Headers.Contains('AjaxSessionKey') -and -not [string]::IsNullOrWhiteSpace($Headers['AjaxSessionKey'])) {
            $UsePortalSession = $true
        } elseif ($Headers.Contains('PortalWebSession') -and $null -ne $Headers['PortalWebSession']) {
            $UsePortalSession = $true
        }
    }

    function Get-AgentToolsSafeResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            $Result = & $ScriptBlock
            if ($null -eq $Result) {
                New-O365UnavailableResult -Name $ResultName -Area 'Agents tools section' -Description 'The Agents tools section did not return a usable payload.'
            } else {
                $Result
            }
        } catch {
            New-O365UnavailableResult -Name $ResultName -Area 'Agents tools section' -Description 'The Agents tools section did not return a usable payload.' -ErrorMessage $_.Exception.Message
        }
    }

    if ($Name -eq 'All') {
        [PSCustomObject] @{
            McpServers = Get-O365AgentTools -Headers $Headers -Name McpServers
        }
        return
    }

    $Uri = 'https://admin.cloud.microsoft/admin/api/agentssettings/mcpservers'
    Get-AgentToolsSafeResult -ResultName 'McpServers' -ScriptBlock { Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -AdditionalHeaders $AdditionalHeaders -UsePortalSession:$UsePortalSession }
}
