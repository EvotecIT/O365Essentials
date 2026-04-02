function Get-O365CopilotSettings {
    <#
    .SYNOPSIS
    Retrieves Copilot settings data from the Microsoft 365 admin center.

    .DESCRIPTION
    Reads internal Copilot settings payloads used by the deployment, optimization,
    and Purview-backed security recommendation experiences in the Microsoft 365 admin center.

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

    $AdditionalHeaders = Get-O365PortalContextHeaders -Context Copilot
    $ResolvedHeaders = if ($Headers) { Connect-O365Admin -Headers $Headers } else { Connect-O365Admin }
    $TenantId = if ($ResolvedHeaders) { $ResolvedHeaders.Tenant } else { $null }
    $WindowEnd = (Get-Date).ToUniversalTime()
    $WindowStart = $WindowEnd.AddDays(-31)
    $PurviewFilter14 = [uri]::EscapeDataString("PurviewAIScenario eq 'P4AIAdhocQuery14' and HostNames eq '' and SensitiveInfoTypes eq 'None'")
    $PolicyFilter = [uri]::EscapeDataString("Identity eq 'Default DLP policy - Protect sensitive M365 Copilot interactions'")
    $StartTime = [uri]::EscapeDataString($WindowStart.ToString('o'))
    $EndTime = [uri]::EscapeDataString($WindowEnd.ToString('o'))

    function Get-CopilotSettingsLeaf {
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
                New-O365UnavailableResult -Name $ResultName -Area 'Copilot settings section' -Description 'The Copilot settings section did not return a usable payload.'
            } else {
                $Result
            }
        } catch {
            New-O365UnavailableResult -Name $ResultName -Area 'Copilot settings section' -Description 'The Copilot settings section did not return a usable payload.' -ErrorMessage $_.Exception.Message
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

    function Get-CopilotOptimizeBundle {
        [PSCustomObject] @{
            Recommendations          = Get-O365CopilotSettings -Headers $Headers -Name Recommendations
            Dismissed                = Get-O365CopilotSettings -Headers $Headers -Name Dismissed
            SecurityCopilotAuth      = Get-O365CopilotSettings -Headers $Headers -Name SecurityCopilotAuth
            AzureSubscriptions       = Get-O365CopilotSettings -Headers $Headers -Name AzureSubscriptions
            CopilotChatBillingPolicy = Get-O365CopilotSettings -Headers $Headers -Name CopilotChatBillingPolicy
            AuditEnabled             = Get-O365CopilotSettings -Headers $Headers -Name AuditEnabled
            AIBaselineSummary        = Get-O365CopilotSettings -Headers $Headers -Name AIBaselineSummary
            PurviewForAISetting      = Get-O365CopilotSettings -Headers $Headers -Name PurviewForAISetting
            ComplianceRecommendation = Get-O365CopilotSettings -Headers $Headers -Name ComplianceRecommendation
            DefaultDlpPolicy         = Get-O365CopilotSettings -Headers $Headers -Name DefaultDlpPolicy
        }
    }

    function Get-CopilotViewAllBundle {
        [PSCustomObject] @{
            Recommendations          = Get-O365CopilotSettings -Headers $Headers -Name Recommendations
            Dismissed                = Get-O365CopilotSettings -Headers $Headers -Name Dismissed
            SecurityCopilotAuth      = Get-O365CopilotSettings -Headers $Headers -Name SecurityCopilotAuth
            AzureSubscriptions       = Get-O365CopilotSettings -Headers $Headers -Name AzureSubscriptions
            CopilotChatBillingPolicy = Get-O365CopilotSettings -Headers $Headers -Name CopilotChatBillingPolicy
        }
    }

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
            Get-CopilotSettingsLeaf -Uri 'https://admin.microsoft.com/admin/api/recommendations/m365/ccs'
            return
        }
        'Dismissed' {
            Get-CopilotSettingsLeaf -Uri 'https://admin.microsoft.com/admin/api/copilotsettings/settings/dismissed'
            return
        }
        'SecurityCopilotAuth' {
            Get-CopilotSafeResult -ResultName 'SecurityCopilotAuth' -ScriptBlock { Get-CopilotSettingsLeaf -Uri 'https://admin.microsoft.com/admin/api/copilotsettings/securitycopilot/auth' }
            return
        }
        'AzureSubscriptions' {
            Get-CopilotSettingsLeaf -Uri 'https://admin.microsoft.com/admin/api/syntexbilling/azureSubscriptions'
            return
        }
        'CopilotChatBillingPolicy' {
            Get-CopilotSettingsLeaf -Uri 'https://admin.microsoft.com/_api/v2.1/billingPolicies?feature=M365CopilotChat'
            return
        }
        'AuditEnabled' {
            Get-CopilotSafeResult -ResultName 'AuditEnabled' -ScriptBlock { Get-CopilotSettingsLeaf -Uri 'https://admin.microsoft.com/fd/purview/apiproxy/adtsch/AuditEnabled' }
            return
        }
        'AIBaselineSummary' {
            Get-CopilotSafeResult -ResultName 'AIBaselineSummary' -ScriptBlock { Get-CopilotSettingsLeaf -Uri 'https://admin.microsoft.com/fd/purview/apiproxy/cpm/v1.0/Tenant/AIBaselineSummary' -AdditionalLeafHeaders (Get-CopilotPurviewHeaders -IncludeClientRequestId) }
            return
        }
        'PurviewForAISetting' {
            Get-CopilotSafeResult -ResultName 'PurviewForAISetting' -ScriptBlock { Get-CopilotSettingsLeaf -Uri "https://admin.microsoft.com/fd/purview/apiproxy/di/find/PurviewForAISetting?tenantId=$TenantId" }
            return
        }
        'ComplianceRecommendation' {
            Get-CopilotSafeResult -ResultName 'ComplianceRecommendation' -ScriptBlock { Get-CopilotSettingsLeaf -Uri "https://admin.microsoft.com/fd/purview/apiproxy/di/find/PurviewForAI?tenantId=$TenantId&filter=$PurviewFilter14&startTime=$StartTime&endTime=$EndTime" }
            return
        }
        'DefaultDlpPolicy' {
            Get-CopilotSafeResult -ResultName 'DefaultDlpPolicy' -ScriptBlock { Get-CopilotSettingsLeaf -Uri "https://admin.microsoft.com/fd/purview/apiproxy/di/find/DlpCompliancePolicy?tenantId=$TenantId&filter=$PolicyFilter" }
            return
        }
    }
}
