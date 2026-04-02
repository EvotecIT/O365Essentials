Import-Module .\O365Essentials.psd1 -Force

$null = Connect-O365Admin -Verbose

Get-O365CopilotOverview -Verbose
Get-O365CopilotOverview -Name Usage -Verbose
Get-O365CopilotOverview -Name Security -Verbose
