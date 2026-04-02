Import-Module .\O365Essentials.psd1 -Force

$null = Connect-O365Admin -Verbose

Get-O365CopilotBillingUsage -Verbose
Get-O365CopilotBillingUsage -Name BillingPolicies -Verbose
Get-O365CopilotBillingUsage -Name HighUsageUsers -Verbose
