function Get-CopilotViewAllBundle {
    [PSCustomObject] @{
        Recommendations          = Get-O365CopilotSettings -Headers $Headers -Name Recommendations
        Dismissed                = Get-O365CopilotSettings -Headers $Headers -Name Dismissed
        SecurityCopilotAuth      = Get-O365CopilotSettings -Headers $Headers -Name SecurityCopilotAuth
        AzureSubscriptions       = Get-O365CopilotSettings -Headers $Headers -Name AzureSubscriptions
        CopilotChatBillingPolicy = Get-O365CopilotSettings -Headers $Headers -Name CopilotChatBillingPolicy
    }
}
