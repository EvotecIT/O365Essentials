Import-Module .\O365Essentials.psd1 -Force

$null = Connect-O365Admin -Verbose

Get-O365AgentOverview -Verbose
Get-O365AgentOverview -Name Summary -Verbose
