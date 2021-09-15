Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant, using credentials
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365SearchIntelligenceBingConfigurations
Set-O365SearchIntelligenceBingConfigurations -ServiceEnabled $true -Verbose -WhatIf

Get-O365SearchIntelligenceBingExtension -Verbose
Set-O365SearchIntelligenceBingExtension -EnableExtension $true -LimitGroupName 'All Users' -Verbose -WhatIf
Set-O365SearchIntelligenceBingExtension -EnableExtension $false -Verbose -WhatIf
Set-O365SearchIntelligenceBingExtension -EnableExtension $true -Verbose -WhatIf