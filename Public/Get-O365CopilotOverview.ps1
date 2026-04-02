function Get-O365CopilotOverview {
    <#
    .SYNOPSIS
    Retrieves Copilot overview data from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal Copilot overview payloads covering high-value overview, security,
    usage, and about routes from the Microsoft 365 admin center.

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

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context Copilot
    $ResolvedHeaders = if ($Headers) { Connect-O365Admin -Headers $Headers } else { Connect-O365Admin }
    $TenantId = if ($ResolvedHeaders) { $ResolvedHeaders.Tenant } else { $null }
    $WindowEnd = (Get-Date).ToUniversalTime()
    $WindowStart = $WindowEnd.AddDays(-31)
    $PolicyFilter = [uri]::EscapeDataString("Identity eq 'Default DLP policy - Protect sensitive M365 Copilot interactions'")
    $PurviewFilter13 = [uri]::EscapeDataString("PurviewAIScenario eq 'P4AIAdhocQuery13' and appCategories eq 'Copilot' and appIdentities eq 'Copilot.MicrosoftCopilot,Copilot.M365Copilot'")
    $PurviewFilter14 = [uri]::EscapeDataString("PurviewAIScenario eq 'P4AIAdhocQuery14' and HostNames eq '' and SensitiveInfoTypes eq 'None'")
    $PurviewFilter15 = [uri]::EscapeDataString("PurviewAIScenario eq 'P4AIAdhocQuery15' and HostNames eq '' and SensitiveInfoTypes eq 'None'")
    $StartTime = [uri]::EscapeDataString($WindowStart.ToString('o'))
    $EndTime = [uri]::EscapeDataString($WindowEnd.ToString('o'))

    function Get-CopilotOverviewLeaf {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $Uri,
            [System.Collections.IDictionary] $AdditionalLeafHeaders = $AdditionalHeaders
        )

        Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -AdditionalHeaders $AdditionalLeafHeaders
    }

    function Get-CopilotSafeResult {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $ResultName,
            [Parameter(Mandatory)][scriptblock] $ScriptBlock
        )

        try {
            $Result = & $ScriptBlock
            if ($null -eq $Result) {
                New-O365UnavailableResult -Name $ResultName -Area 'Copilot overview section' -Description 'The Copilot overview section did not return a usable payload.'
            } else {
                $Result
            }
        } catch {
            New-O365UnavailableResult -Name $ResultName -Area 'Copilot overview section' -Description 'The Copilot overview section did not return a usable payload.' -ErrorMessage $_.Exception.Message
        }
    }

    function Get-CopilotPurviewHeaders {
        [cmdletbinding()]
        param(
            [switch] $IncludeClientRequestId
        )

        $PurviewHeaders = [ordered] @{
            tenantid             = $TenantId
            'x-tid'              = $TenantId
            'client-type'        = 'purview'
            'x-clientpage'       = '/'
            'client-version'     = '1.0.2774.1'
            'x-tabvisible'       = 'visible'
            'x-clientpkgversion' = ''
        }

        if ($IncludeClientRequestId) {
            $PurviewHeaders['client-request-id'] = [guid]::NewGuid().ToString()
        }

        foreach ($Key in $AdditionalHeaders.Keys) {
            $PurviewHeaders[$Key] = $AdditionalHeaders[$Key]
        }

        $PurviewHeaders
    }

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
                CopilotSettings             = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/copilotsettings/settings'
                PinPolicy                   = Get-O365CopilotPin -Headers $Headers
                LicenseAssignmentDate       = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/Copilot/getcopilotlicenseassignmentdate'
                CapacityPackUsage           = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/_api/v2.1/copilot/capacitypack/checkUsage'
                AdoptionSummary             = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/fd/IDEAsKnowledgeService/api/odata/v2.0.0/OrganizationM365CopilotAdoption'
                AdoptionByProducts          = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetReportData?entityName=getCopilotAdoptionByProductsV2'
                AdoptionByDate              = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetReportData?entityName=getCopilotAdoptionByDateV2'
                CopilotChatAdoptionByPeriod = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetReportData?entityName=getCopilotEDPAdoptionByPeriodV2'
                CopilotChatAdoptionByDate   = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetReportData?entityName=getCopilotEDPAdoptionByDateV2'
                ThumbsUpRate                = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetReportData?entityName=getCopilotThumbsUpRateByDate'
                CopilotChatThumbsUpRate     = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetReportData?entityName=getCopilotEDPThumbsUpRateByDate'
                AgentActiveUsers            = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetReportData?entityName=getCopilotAgentActiveUserRL30DailyMetrics'
                ActiveAgents                = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetReportData?entityName=getCopilotAgentActiveAgentRL30Metrics'
                SubscribedSkus              = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/fd/MSGraph/v1.0/subscribedSkus'
            }
            return
        }
        'Security' {
            [PSCustomObject] @{
                PurviewBootInfo           = Get-CopilotSafeResult -ResultName 'PurviewBootInfo' -ScriptBlock { Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/fd/purview/api/boot/getNexusBootInfo' }
                PurviewRoles              = Get-CopilotSafeResult -ResultName 'PurviewRoles' -ScriptBlock { Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/fd/purview/api/v2/auth/GetCachedRoles?refreshCache=false' }
                PurviewSettings           = Get-CopilotSafeResult -ResultName 'PurviewSettings' -ScriptBlock { Get-CopilotOverviewLeaf -Uri "https://admin.microsoft.com/fd/purview/apiproxy/di/find/PurviewForAISetting?tenantId=$TenantId" }
                AIBaselineSummary         = Get-CopilotSafeResult -ResultName 'AIBaselineSummary' -ScriptBlock { Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/fd/purview/apiproxy/cpm/v1.0/Tenant/AIBaselineSummary' -AdditionalLeafHeaders (Get-CopilotPurviewHeaders -IncludeClientRequestId) }
                DefaultDlpPolicy          = Get-CopilotSafeResult -ResultName 'DefaultDlpPolicy' -ScriptBlock { Get-CopilotOverviewLeaf -Uri "https://admin.microsoft.com/fd/purview/apiproxy/di/find/DlpCompliancePolicy?tenantId=$TenantId&filter=$PolicyFilter" }
                SensitiveInfoTypes        = Get-CopilotSafeResult -ResultName 'SensitiveInfoTypes' -ScriptBlock { Get-CopilotOverviewLeaf -Uri "https://admin.microsoft.com/fd/purview/apiproxy/di/find/DlpSensitiveInformationType?tenantId=$TenantId" }
                OversharingRecommendation = Get-CopilotSafeResult -ResultName 'OversharingRecommendation' -ScriptBlock { Get-CopilotOverviewLeaf -Uri "https://admin.microsoft.com/fd/purview/apiproxy/di/find/PurviewForAI?tenantId=$TenantId&filter=$PurviewFilter13&startTime=$StartTime&endTime=$EndTime" }
                ComplianceRecommendation  = Get-CopilotSafeResult -ResultName 'ComplianceRecommendation' -ScriptBlock { Get-CopilotOverviewLeaf -Uri "https://admin.microsoft.com/fd/purview/apiproxy/di/find/PurviewForAI?tenantId=$TenantId&filter=$PurviewFilter14&startTime=$StartTime&endTime=$EndTime" }
                DataLeakRecommendation    = Get-CopilotSafeResult -ResultName 'DataLeakRecommendation' -ScriptBlock { Get-CopilotOverviewLeaf -Uri "https://admin.microsoft.com/fd/purview/apiproxy/di/find/PurviewForAI?tenantId=$TenantId&filter=$PurviewFilter15&startTime=$StartTime&endTime=$EndTime" }
            }
            return
        }
        'Usage' {
            [PSCustomObject] @{
                Readiness                  = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/fd/IDEAsKnowledgeService/api/odata/v1.0.0/OrganizationM365CopilotReadiness'
                AdoptionByProducts         = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetSummaryDataV3?ServiceId=MicrosoftOffice&CategoryId=MicrosoftCopilot&Report=CopilotActivityReport&active_view=CopilotAdoptionByProductsV2'
                AdoptionByDate             = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetSummaryDataV3?ServiceId=MicrosoftOffice&CategoryId=MicrosoftCopilot&Report=CopilotActivityReport&active_view=CopilotAdoptionByDateV2'
                CopilotChatSummary         = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetSummaryDataV3?ServiceId=MicrosoftOffice&CategoryId=MicrosoftCopilotBCE&Report=CopilotBCEActivityReport&active_view=CopilotEDPAdoptionSummaryByPeriodV2'
                CopilotChatAdoptionByPeriod = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetSummaryDataV3?ServiceId=MicrosoftOffice&CategoryId=MicrosoftCopilotBCE&Report=CopilotBCEActivityReport&active_view=CopilotBCEAdoptionByPeriodV2'
                CopilotChatAdoptionByDate  = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetSummaryDataV3?ServiceId=MicrosoftOffice&CategoryId=MicrosoftCopilotBCE&Report=CopilotBCEActivityReport&active_view=CopilotBCEAdoptionByDateV2'
                SearchUsage                = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetReportData?entityname=getTenantSearchMetric&period=30&locale=en-US'
                CreditUsage                = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetReportData?entityname=getMessageConsumptionSummary&period=30&locale=en-US'
                AgentUsage                 = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/reports/GetReportData?entityname=getDeclarativeAgentConsumptionSummary&locale=en-US'
                PinPolicy                  = Get-O365CopilotPin -Headers $Headers
                LicenseAssignmentDate      = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/Copilot/getcopilotlicenseassignmentdate'
            }
            return
        }
        'About' {
            [PSCustomObject] @{
                Discover              = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/copilotsettings/copilot/discover'
                OfferRecommendations  = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/offerrec/copilotagentsoffers/CopilotDiscoverPage'
                MarketplaceSeatSize   = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/tenant/marketplaceSeatSize'
                SubscribedSkus        = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/fd/MSGraph/v1.0/subscribedSkus'
                PinPolicy             = Get-O365CopilotPin -Headers $Headers
                LicenseAssignmentDate = Get-CopilotOverviewLeaf -Uri 'https://admin.microsoft.com/admin/api/Copilot/getcopilotlicenseassignmentdate'
            }
            return
        }
    }
}
