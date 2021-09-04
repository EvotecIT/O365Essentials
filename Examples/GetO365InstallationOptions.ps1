Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
  $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant, using credentials
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

$Options = Get-O365OrgInstallationOptions -Verbose
$Options

Set-O365OrgInstallationOptions -Verbose -MacSkypeForBusiness $false -WindowsSkypeForBusiness $false -WindowsBranch CurrentChannel -WhatIf