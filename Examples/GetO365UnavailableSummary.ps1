Import-Module .\O365Essentials.psd1 -Force

$null = Connect-O365Admin -Verbose

$Result = Get-O365CopilotOverview -Name Security -Verbose
Get-O365UnavailableSummary -InputObject $Result
