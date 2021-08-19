Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
$Authorization = Connect-O365Admin -Verbose -Credential $Credentials

Set-O365Planner -Authorization $Authorization -AllowCalendarSharing $true
Set-O365Forms -Authorization $Authorization -InOrgFormsPhishingScanEnabled $true
Set-O365AzureSpeechServices -Authorization $Authorization -AllowTheOrganizationWideLanguageModel $false