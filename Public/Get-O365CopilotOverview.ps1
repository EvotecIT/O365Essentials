function Get-O365CopilotOverview {
    <#
    .SYNOPSIS
    Retrieves Copilot overview data from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal Copilot overview payloads covering high-value overview, security,
    usage, and about routes from the Microsoft 365 admin center.

    The overview bundle mixes bearer-token-friendly routes with routes that often require
    a live admin.cloud.microsoft portal session. The cmdlet therefore prefers portal replay
    when available and converts missing or portal-sensitive leaves into structured
    unavailable results instead of treating every no-data response as a hard failure.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which Copilot overview payload group to return.

    .EXAMPLE
    Get-O365CopilotOverview

    .EXAMPLE
    Get-O365CopilotOverview -Name Usage

    .EXAMPLE
    Get-O365CopilotOverview -Name Security
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('About', 'All', 'Overview', 'Security', 'Usage')][string] $Name = 'All'
    )

    $ResolvedHeaders = if ($Headers) { $Headers } else { Connect-O365Admin }
    if ($ResolvedHeaders -and -not $ResolvedHeaders.Contains('Tenant') -and -not $ResolvedHeaders.Contains('TenantId')) {
        $ResolvedHeaders = if ($Headers) { Connect-O365Admin -Headers $Headers } else { Connect-O365Admin }
    }
    $TenantId = if ($ResolvedHeaders) {
        if ($ResolvedHeaders.Contains('Tenant') -and -not [string]::IsNullOrWhiteSpace($ResolvedHeaders['Tenant'])) {
            $ResolvedHeaders['Tenant']
        }
        elseif ($ResolvedHeaders.Contains('TenantId') -and -not [string]::IsNullOrWhiteSpace($ResolvedHeaders['TenantId'])) {
            $ResolvedHeaders['TenantId']
        }
        else {
            $null
        }
    }
    else {
        $null
    }
    $RequestHeaders = if ($Headers) { $Headers } else { $ResolvedHeaders }
    $AdditionalHeaders = Get-O365PortalContextHeaders -Context Copilot -PortalHost 'https://admin.cloud.microsoft' -AjaxSessionKey $RequestHeaders.AjaxSessionKey -PortalRouteKey $RequestHeaders.PortalRouteKey
    $HasPortalSessionContext = $false
    if ($RequestHeaders) {
        if ($RequestHeaders.Contains('AjaxSessionKey') -and -not [string]::IsNullOrWhiteSpace($RequestHeaders['AjaxSessionKey'])) {
            $HasPortalSessionContext = $true
        }
        elseif ($RequestHeaders.Contains('PortalWebSession') -and $null -ne $RequestHeaders['PortalWebSession']) {
            $HasPortalSessionContext = $true
        }
    }
    $WindowEnd = (Get-Date).ToUniversalTime()
    $WindowStart = $WindowEnd.AddDays(-31)
    $PolicyFilter = [uri]::EscapeDataString("Identity eq 'Default DLP policy - Protect sensitive M365 Copilot interactions'")
    $PurviewFilter13 = [uri]::EscapeDataString("PurviewAIScenario eq 'P4AIAdhocQuery13' and appCategories eq 'Copilot' and appIdentities eq 'Copilot.MicrosoftCopilot,Copilot.M365Copilot'")
    $PurviewFilter14 = [uri]::EscapeDataString("PurviewAIScenario eq 'P4AIAdhocQuery14' and HostNames eq '' and SensitiveInfoTypes eq 'None'")
    $PurviewFilter15 = [uri]::EscapeDataString("PurviewAIScenario eq 'P4AIAdhocQuery15' and HostNames eq '' and SensitiveInfoTypes eq 'None'")
    $StartTime = [uri]::EscapeDataString($WindowStart.ToString('o'))
    $EndTime = [uri]::EscapeDataString($WindowEnd.ToString('o'))

    switch ($Name) {
        'All' {
            [PSCustomObject] @{
                Overview = Get-O365CopilotOverview -Headers $Headers -Name Overview
                Security = Get-O365CopilotOverview -Headers $Headers -Name Security
                Usage    = Get-O365CopilotOverview -Headers $Headers -Name Usage
                About    = Get-O365CopilotOverview -Headers $Headers -Name About
            }
            return
        }
        'Overview' {
            [PSCustomObject] @{
                CopilotSettings             = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/copilotsettings/settings'
                PinPolicy                   = Get-O365CopilotPin -Headers $Headers
                LicenseAssignmentDate       = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/Copilot/getcopilotlicenseassignmentdate'
                CapacityPackUsage           = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/_api/v2.1/copilot/capacitypack/checkUsage'
                AdoptionSummary             = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/fd/IDEAsKnowledgeService/api/odata/v2.0.0/OrganizationM365CopilotAdoption'
                AdoptionByProducts          = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityName=getCopilotAdoptionByProductsV2'
                AdoptionByDate              = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityName=getCopilotAdoptionByDateV2'
                CopilotChatAdoptionByPeriod = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityName=getCopilotEDPAdoptionByPeriodV2'
                CopilotChatAdoptionByDate   = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityName=getCopilotEDPAdoptionByDateV2'
                ThumbsUpRate                = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityName=getCopilotThumbsUpRateByDate'
                CopilotChatThumbsUpRate     = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityName=getCopilotEDPThumbsUpRateByDate'
                AgentActiveUsers            = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityName=getCopilotAgentActiveUserRL30DailyMetrics'
                ActiveAgents                = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityName=getCopilotAgentActiveAgentRL30Metrics'
                SubscribedSkus              = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/fd/MSGraph/v1.0/subscribedSkus'
            }
            return
        }
        'Security' {
            [PSCustomObject] @{
                PurviewBootInfo           = Invoke-O365SectionSafeResult -Section CopilotOverview -ResultName 'PurviewBootInfo' -ScriptBlock { Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/fd/purview/api/boot/getNexusBootInfo' }
                PurviewRoles              = Invoke-O365SectionSafeResult -Section CopilotOverview -ResultName 'PurviewRoles' -ScriptBlock { Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/fd/purview/api/v2/auth/GetCachedRoles?refreshCache=false' }
                PurviewSettings           = Invoke-O365SectionSafeResult -Section CopilotOverview -ResultName 'PurviewSettings' -ScriptBlock { Get-CopilotOverviewLeaf -Uri "https://admin.cloud.microsoft/fd/purview/apiproxy/di/find/PurviewForAISetting?tenantId=$TenantId" }
                AIBaselineSummary         = Invoke-O365SectionSafeResult -Section CopilotOverview -ResultName 'AIBaselineSummary' -ScriptBlock { Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/fd/purview/apiproxy/cpm/v1.0/Tenant/AIBaselineSummary' -AdditionalLeafHeaders (Get-CopilotPurviewHeaders -IncludeClientRequestId) }
                DefaultDlpPolicy          = Invoke-O365SectionSafeResult -Section CopilotOverview -ResultName 'DefaultDlpPolicy' -ScriptBlock { Get-CopilotOverviewLeaf -Uri "https://admin.cloud.microsoft/fd/purview/apiproxy/di/find/DlpCompliancePolicy?tenantId=$TenantId&filter=$PolicyFilter" }
                SensitiveInfoTypes        = Invoke-O365SectionSafeResult -Section CopilotOverview -ResultName 'SensitiveInfoTypes' -ScriptBlock { Get-CopilotOverviewLeaf -Uri "https://admin.cloud.microsoft/fd/purview/apiproxy/di/find/DlpSensitiveInformationType?tenantId=$TenantId" }
                OversharingRecommendation = Invoke-O365SectionSafeResult -Section CopilotOverview -ResultName 'OversharingRecommendation' -ScriptBlock { Get-CopilotOverviewLeaf -Uri "https://admin.cloud.microsoft/fd/purview/apiproxy/di/find/PurviewForAI?tenantId=$TenantId&filter=$PurviewFilter13&startTime=$StartTime&endTime=$EndTime" }
                ComplianceRecommendation  = Invoke-O365SectionSafeResult -Section CopilotOverview -ResultName 'ComplianceRecommendation' -ScriptBlock { Get-CopilotOverviewLeaf -Uri "https://admin.cloud.microsoft/fd/purview/apiproxy/di/find/PurviewForAI?tenantId=$TenantId&filter=$PurviewFilter14&startTime=$StartTime&endTime=$EndTime" }
                DataLeakRecommendation    = Invoke-O365SectionSafeResult -Section CopilotOverview -ResultName 'DataLeakRecommendation' -ScriptBlock { Get-CopilotOverviewLeaf -Uri "https://admin.cloud.microsoft/fd/purview/apiproxy/di/find/PurviewForAI?tenantId=$TenantId&filter=$PurviewFilter15&startTime=$StartTime&endTime=$EndTime" }
            }
            return
        }
        'Usage' {
            [PSCustomObject] @{
                Readiness                   = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/fd/IDEAsKnowledgeService/api/odata/v1.0.0/OrganizationM365CopilotReadiness'
                AdoptionByProducts          = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetSummaryDataV3?ServiceId=MicrosoftOffice&CategoryId=MicrosoftCopilot&Report=CopilotActivityReport&active_view=CopilotAdoptionByProductsV2'
                AdoptionByDate              = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetSummaryDataV3?ServiceId=MicrosoftOffice&CategoryId=MicrosoftCopilot&Report=CopilotActivityReport&active_view=CopilotAdoptionByDateV2'
                CopilotChatSummary          = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetSummaryDataV3?ServiceId=MicrosoftOffice&CategoryId=MicrosoftCopilotBCE&Report=CopilotBCEActivityReport&active_view=CopilotEDPAdoptionSummaryByPeriodV2'
                CopilotChatAdoptionByPeriod = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetSummaryDataV3?ServiceId=MicrosoftOffice&CategoryId=MicrosoftCopilotBCE&Report=CopilotBCEActivityReport&active_view=CopilotBCEAdoptionByPeriodV2'
                CopilotChatAdoptionByDate   = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetSummaryDataV3?ServiceId=MicrosoftOffice&CategoryId=MicrosoftCopilotBCE&Report=CopilotBCEActivityReport&active_view=CopilotBCEAdoptionByDateV2'
                SearchUsage                 = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityname=getTenantSearchMetric&period=30&locale=en-US'
                CreditUsage                 = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityname=getMessageConsumptionSummary&period=30&locale=en-US'
                AgentUsage                  = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/reports/GetReportData?entityname=getDeclarativeAgentConsumptionSummary&locale=en-US'
                PinPolicy                   = Get-O365CopilotPin -Headers $Headers
                LicenseAssignmentDate       = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/Copilot/getcopilotlicenseassignmentdate'
            }
            return
        }
        'About' {
            [PSCustomObject] @{
                Discover              = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/copilotsettings/copilot/discover'
                OfferRecommendations  = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/offerrec/copilotagentsoffers/CopilotDiscoverPage'
                MarketplaceSeatSize   = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/tenant/marketplaceSeatSize'
                SubscribedSkus        = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/fd/MSGraph/v1.0/subscribedSkus'
                PinPolicy             = Get-O365CopilotPin -Headers $Headers
                LicenseAssignmentDate = Get-CopilotOverviewLeaf -Uri 'https://admin.cloud.microsoft/admin/api/Copilot/getcopilotlicenseassignmentdate'
            }
            return
        }
    }
}
