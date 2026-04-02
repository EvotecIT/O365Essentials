Import-Module .\O365Essentials.psd1 -Force

$null = Connect-O365Admin -Verbose

Get-O365ContentUnderstanding -Name Setting -Verbose
Get-O365ContentUnderstanding -Name BillingSettings -Verbose
