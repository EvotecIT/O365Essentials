Import-Module .\O365Essentials.psd1 -Force

$null = Connect-O365Admin -Verbose

Get-O365CopilotSettings -Verbose
Get-O365CopilotSettings -Name Recommendations -Verbose
Get-O365CopilotSettings -Name AuditEnabled -Verbose
