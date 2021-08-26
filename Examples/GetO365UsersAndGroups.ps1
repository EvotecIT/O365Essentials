Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365Group -Id 'e7772951-4b0e-4f10-8f38-eae9b8f55962' -Verbose | Format-Table
Get-O365Group -EmailAddress 'test@evotec.pl' -Verbose | Format-Table
Get-O365Group -DisplayName 'Wszyscy' -Verbose | Format-Table
Get-O365Group -Verbose -Property 'id','displayName','securityEnabled','mail','mailEnabled' | Format-Table


Get-O365GroupMember -Id 'e7772951-4b0e-4f10-8f38-eae9b8f55962' -Verbose | Format-Table

Get-O365User -GuestsOnly -Verbose | Format-Table
Get-O365User -UserPrincipalName 'przemyslaw.klys@evotec.pl' -Verbose | Format-Table
Get-O365User -EmailAddress 'przemyslaw.klys@evotec.pl' -Verbose | Format-Table