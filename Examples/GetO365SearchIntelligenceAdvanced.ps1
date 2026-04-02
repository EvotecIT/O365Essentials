Import-Module .\O365Essentials.psd1 -Force

$null = Connect-O365Admin -Verbose

Get-O365SearchIntelligenceAdvanced -Name ConfigurationSettings -Verbose
Get-O365SearchIntelligenceAdvanced -Name Qnas -QnasServiceType 'Bing' -QnasFilter 'Published' -Verbose
