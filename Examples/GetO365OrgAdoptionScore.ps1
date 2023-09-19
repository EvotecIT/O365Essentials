Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365OrgAdoptionScore | Format-List

# this one is not sure what for
#Get-O365OrgAdoptionScoreConfig -Verbose | Format-Table

Set-O365OrgAdoptionScore -EnableInsights $false -TurnOnGroupLevelInsights $false -AllowApprovedAdminsToSendRecommendations $false

Set-O365OrgAdoptionScore -EnableInsights $true -TurnOnGroupLevelInsights $false -AllowApprovedAdminsToSendRecommendations $false