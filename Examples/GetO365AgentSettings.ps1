Import-Module .\O365Essentials.psd1 -Force

$null = Connect-O365Admin -Verbose

Get-O365AgentSettings -Verbose
Get-O365AgentSettings -Name AllowedAgentTypes -Verbose
