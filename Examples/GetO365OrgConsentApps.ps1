Import-Module .\O365Essentials.psd1 -Force

# Connect using interactive sign in (MFA supported)
$null = Connect-O365Admin -Verbose

Get-O365OrgUserConsentApps

Set-O365OrgUserConsentApps -UserConsentToApps AllowLimited -Verbose