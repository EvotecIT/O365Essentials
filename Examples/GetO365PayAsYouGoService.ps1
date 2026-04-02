Import-Module .\O365Essentials.psd1 -Force

$null = Connect-O365Admin -Verbose

Get-O365PayAsYouGoService -Verbose
Get-O365PayAsYouGoService -Name DataLocationAndCommitments -Verbose
Get-O365PayAsYouGoService -Name Telemetry -Verbose
