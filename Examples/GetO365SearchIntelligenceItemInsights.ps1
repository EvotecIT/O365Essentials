Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant, using credentials
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365SearchIntelligenceItemInsights -Verbose | Format-Table
Get-O365SearchIntelligenceMeetingInsights -Verbose | Format-Table
Set-O365SearchIntelligenceItemInsights -Verbose -AllowItemInsights $false -WhatIf
Set-O365SearchIntelligenceMeetingInsights -Verbose -AllowMeetingInsights $true -WhatIf