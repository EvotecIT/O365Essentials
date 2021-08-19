Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
$null = Connect-O365Admin -Verbose -Credential $Credentials

Set-O365Planner -AllowCalendarSharing $true
Set-O365Forms -InOrgFormsPhishingScanEnabled $true
Set-O365AzureSpeechServices -AllowTheOrganizationWideLanguageModel $false