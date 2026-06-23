function Invoke-O365SectionSafeResult {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][ValidateSet(
            'AgentsOverview',
            'AgentsSettings',
            'AgentsTools',
            'Backup',
            'BrandCenter',
            'ContentUnderstanding',
            'CopilotBilling',
            'CopilotConnector',
            'CopilotOverview',
            'CopilotSettings',
            'IntegratedApps',
            'PayAsYouGo',
            'People',
            'SearchAdvanced',
            'TenantRelationship'
        )][string] $Section,

        [Parameter(Mandatory)][string] $ResultName,
        [Parameter(Mandatory)][scriptblock] $ScriptBlock
    )

    $SectionDefaults = @{
        AgentsOverview       = @{
            Area        = 'Agents overview section'
            Description = 'The Agents overview section did not return a usable payload.'
        }
        AgentsSettings       = @{
            Area        = 'Agents settings section'
            Description = 'The Agents settings section did not return a usable payload.'
        }
        AgentsTools          = @{
            Area        = 'Agents tools section'
            Description = 'The Agents tools section did not return a usable payload.'
        }
        Backup               = @{
            Area        = 'Microsoft 365 Backup section'
            Description = 'The Microsoft 365 Backup section did not return a usable payload.'
        }
        BrandCenter          = @{
            Area        = 'Brand Center section'
            Description = 'The Brand Center section did not return a usable payload.'
        }
        ContentUnderstanding = @{
            Area        = 'Content Understanding section'
            Description = 'The Content Understanding section did not return a usable payload.'
        }
        CopilotBilling       = @{
            Area                         = 'Copilot billing and usage section'
            Description                  = 'The Copilot billing and usage section did not return a usable payload.'
            SuggestedAction              = 'Verify the tenant has Copilot billing features enabled, the signed-in account has the required admin role, and the route is available in the current portal experience.'
            RequiresPortalSession        = $true
            PortalSessionDescription     = 'The Copilot billing and usage section appears to require an authenticated admin.cloud.microsoft portal session with AjaxSessionKey or portal cookies in addition to bearer-token auth.'
            PortalSessionSuggestedAction = 'Replay the request through a validated admin.cloud.microsoft portal session or supply portal session state before retrying this Copilot surface.'
        }
        CopilotConnector     = @{
            Area                         = 'Copilot connectors section'
            Description                  = 'The Copilot connectors section did not return a usable payload.'
            SuggestedAction              = 'Verify the tenant has Copilot connectors features enabled, the signed-in account has the required admin role, and the route is available in the current portal experience.'
            RequiresPortalSession        = $true
            PortalSessionDescription     = 'The Copilot connectors section appears to require an authenticated admin.cloud.microsoft portal session with AjaxSessionKey or portal cookies in addition to bearer-token auth.'
            PortalSessionSuggestedAction = 'Replay the request through a validated admin.cloud.microsoft portal session or supply portal session state before retrying this Copilot surface.'
        }
        CopilotOverview      = @{
            Area                         = 'Copilot overview section'
            Description                  = 'The Copilot overview section did not return a usable payload.'
            SuggestedAction              = 'Verify the tenant has Copilot overview features enabled, the signed-in account has the required admin role, and the route is available in the current portal experience.'
            RequiresPortalSession        = $true
            PortalSessionDescription     = 'The Copilot overview section appears to require an authenticated admin.cloud.microsoft portal session with AjaxSessionKey or portal cookies in addition to bearer-token auth.'
            PortalSessionSuggestedAction = 'Replay the request through a validated admin.cloud.microsoft portal session or supply portal session state before retrying this Copilot surface.'
        }
        CopilotSettings      = @{
            Area                         = 'Copilot settings section'
            Description                  = 'The Copilot settings section did not return a usable payload.'
            SuggestedAction              = 'Verify the tenant has Copilot settings enabled, the signed-in account has the required admin role, and the route is available in the current portal experience.'
            RequiresPortalSession        = $true
            PortalSessionDescription     = 'The Copilot settings section appears to require an authenticated admin.cloud.microsoft portal session with AjaxSessionKey or portal cookies in addition to bearer-token auth.'
            PortalSessionSuggestedAction = 'Replay the request through a validated admin.cloud.microsoft portal session or supply portal session state before retrying this Copilot surface.'
        }
        IntegratedApps       = @{
            Area        = 'Integrated apps section'
            Description = 'The integrated apps section did not return a usable payload.'
        }
        PayAsYouGo           = @{
            Area        = 'Pay-as-you-go services section'
            Description = 'The pay-as-you-go services section did not return a usable payload.'
        }
        People               = @{
            Area        = 'People settings section'
            Description = 'The People settings section did not return a usable payload.'
        }
        SearchAdvanced       = @{
            UnavailableCommandName = 'New-SearchUnavailableResult'
        }
        TenantRelationship   = @{
            Area        = 'Tenant relationship section'
            Description = 'The tenant relationship section did not return a usable payload.'
        }
    }

    $Defaults = $SectionDefaults[$Section]

    try {
        $Result = & $ScriptBlock
        if ($null -ne $Result) {
            return $Result
        }

        if ($Defaults.UnavailableCommandName) {
            & $Defaults.UnavailableCommandName -ResultName $ResultName
        }
        else {
            $Reason = if ($Defaults.Reason) { $Defaults.Reason } else { 'TenantSpecific' }
            $Description = $Defaults.Description
            $SuggestedAction = $Defaults.SuggestedAction

            if ($Defaults.RequiresPortalSession -and (-not $HasPortalSessionContext)) {
                $Reason = 'PortalSessionRequired'
                $Description = $Defaults.PortalSessionDescription
                $SuggestedAction = $Defaults.PortalSessionSuggestedAction
            }

            New-O365UnavailableResult -Name $ResultName -Area $Defaults.Area -Description $Description -Reason $Reason -SuggestedAction $SuggestedAction
        }
    }
    catch {
        if ($Defaults.UnavailableCommandName) {
            & $Defaults.UnavailableCommandName -ResultName $ResultName -ErrorMessage $_.Exception.Message
        }
        else {
            $Reason = if ($Defaults.Reason) { $Defaults.Reason } else { 'TenantSpecific' }
            $Description = $Defaults.Description
            $SuggestedAction = $Defaults.SuggestedAction

            if ($Defaults.RequiresPortalSession -and (-not $HasPortalSessionContext -or $_.Exception.Message -match '\b440\b')) {
                $Reason = 'PortalSessionRequired'
                $Description = $Defaults.PortalSessionDescription
                $SuggestedAction = $Defaults.PortalSessionSuggestedAction
            }

            New-O365UnavailableResult -Name $ResultName -Area $Defaults.Area -Description $Description -Reason $Reason -ErrorMessage $_.Exception.Message -SuggestedAction $SuggestedAction
        }
    }
}
