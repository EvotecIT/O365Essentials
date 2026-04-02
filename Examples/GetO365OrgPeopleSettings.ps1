Import-Module .\O365Essentials.psd1 -Force

$null = Connect-O365Admin -Verbose

Get-O365OrgPeopleSettings -Verbose
Get-O365OrgPeopleSettings -Name Pronouns -Verbose
