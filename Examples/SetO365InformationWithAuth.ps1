Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
$Authorization = Connect-O365Admin -Verbose -Credential $Credentials

Set-O365OrgPlanner -Authorization $Authorization -AllowCalendarSharing $true
Set-O365OrgForms -Authorization $Authorization -InOrgFormsPhishingScanEnabled $true
Set-O365OrgAzureSpeechServices -Authorization $Authorization -AllowTheOrganizationWideLanguageModel $false