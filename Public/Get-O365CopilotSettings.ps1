function Get-O365CopilotSettings {
    <#
    .SYNOPSIS
    Retrieves Copilot settings data from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal Copilot settings payloads used by the deployment, optimization,
    and Purview-backed security recommendation experiences in the Microsoft 365 admin center.

    The cmdlet reuses the current O365Essentials connection when possible and prefers
    admin.cloud.microsoft portal replay automatically when AjaxSessionKey or a portal
    WebSession is present. Routes that still cannot be read are surfaced as structured
    unavailable results so callers can distinguish tenant/portal requirements from code failures.

    .PARAMETER Headers
    Optional authorization cache returned by Connect-O365Admin.

    .PARAMETER Name
    Selects which Copilot settings payload group to return.

    .EXAMPLE
    Get-O365CopilotSettings

    .EXAMPLE
    Get-O365CopilotSettings -Name Recommendations

    .EXAMPLE
    Get-O365CopilotSettings -Name AuditEnabled
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [ValidateSet('AIBaselineSummary', 'All', 'AuditEnabled', 'AzureSubscriptions', 'ComplianceRecommendation', 'CopilotChatBillingPolicy', 'DefaultDlpPolicy', 'Dismissed', 'Optimize', 'PurviewForAISetting', 'Recommendations', 'SecurityCopilotAuth', 'ViewAll')][string] $Name = 'All'
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
    $AdditionalHeaders = Get-O365PortalContextHeaders -Context CopilotSettings -PortalHost 'https://admin.cloud.microsoft' -AjaxSessionKey $RequestHeaders.AjaxSessionKey -PortalRouteKey $RequestHeaders.PortalRouteKey
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
    $PurviewFilter14 = [uri]::EscapeDataString("PurviewAIScenario eq 'P4AIAdhocQuery14' and HostNames eq '' and SensitiveInfoTypes eq 'None'")
    $PolicyFilter = [uri]::EscapeDataString("Identity eq 'Default DLP policy - Protect sensitive M365 Copilot interactions'")
    $StartTime = [uri]::EscapeDataString($WindowStart.ToString('o'))
    $EndTime = [uri]::EscapeDataString($WindowEnd.ToString('o'))

    switch ($Name) {
        'All' {
            [PSCustomObject] @{
                Optimize = Get-O365CopilotSettings -Headers $Headers -Name Optimize
                ViewAll  = Get-O365CopilotSettings -Headers $Headers -Name ViewAll
            }
            return
        }
        'Optimize' {
            Get-CopilotOptimizeBundle
            return
        }
        'ViewAll' {
            Get-CopilotViewAllBundle
            return
        }
        'Recommendations' {
            Get-CopilotSettingsLeaf -Uri 'https://admin.cloud.microsoft/admin/api/recommendations/m365/ccs'
            return
        }
        'Dismissed' {
            Get-CopilotSettingsLeaf -Uri 'https://admin.cloud.microsoft/admin/api/copilotsettings/settings/dismissed'
            return
        }
        'SecurityCopilotAuth' {
            Invoke-O365SectionSafeResult -Section CopilotSettings -ResultName 'SecurityCopilotAuth' -ScriptBlock { Get-CopilotSettingsLeaf -Uri 'https://admin.cloud.microsoft/admin/api/copilotsettings/securitycopilot/auth' }
            return
        }
        'AzureSubscriptions' {
            Get-CopilotSettingsLeaf -Uri 'https://admin.cloud.microsoft/admin/api/syntexbilling/azureSubscriptions'
            return
        }
        'CopilotChatBillingPolicy' {
            Get-CopilotSettingsLeaf -Uri 'https://admin.cloud.microsoft/_api/v2.1/billingPolicies?feature=M365CopilotChat' -AdditionalLeafHeaders (Get-CopilotSPOHeaders)
            return
        }
        'AuditEnabled' {
            Invoke-O365SectionSafeResult -Section CopilotSettings -ResultName 'AuditEnabled' -ScriptBlock { Get-CopilotSettingsLeaf -Uri 'https://admin.cloud.microsoft/fd/purview/apiproxy/adtsch/AuditEnabled' }
            return
        }
        'AIBaselineSummary' {
            Invoke-O365SectionSafeResult -Section CopilotSettings -ResultName 'AIBaselineSummary' -ScriptBlock { Get-CopilotSettingsLeaf -Uri 'https://admin.cloud.microsoft/fd/purview/apiproxy/cpm/v1.0/Tenant/AIBaselineSummary' -AdditionalLeafHeaders (Get-CopilotPurviewHeaders -IncludeClientRequestId) }
            return
        }
        'PurviewForAISetting' {
            Invoke-O365SectionSafeResult -Section CopilotSettings -ResultName 'PurviewForAISetting' -ScriptBlock { Get-CopilotSettingsLeaf -Uri "https://admin.cloud.microsoft/fd/purview/apiproxy/di/find/PurviewForAISetting?tenantId=$TenantId" }
            return
        }
        'ComplianceRecommendation' {
            Invoke-O365SectionSafeResult -Section CopilotSettings -ResultName 'ComplianceRecommendation' -ScriptBlock { Get-CopilotSettingsLeaf -Uri "https://admin.cloud.microsoft/fd/purview/apiproxy/di/find/PurviewForAI?tenantId=$TenantId&filter=$PurviewFilter14&startTime=$StartTime&endTime=$EndTime" }
            return
        }
        'DefaultDlpPolicy' {
            Invoke-O365SectionSafeResult -Section CopilotSettings -ResultName 'DefaultDlpPolicy' -ScriptBlock { Get-CopilotSettingsLeaf -Uri "https://admin.cloud.microsoft/fd/purview/apiproxy/di/find/DlpCompliancePolicy?tenantId=$TenantId&filter=$PolicyFilter" }
            return
        }
    }
}
