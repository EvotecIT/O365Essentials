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
