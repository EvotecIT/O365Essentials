Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365CommunicationToUsers # not really working

Get-O365Domain -Verbose | Format-Table

Get-O365DomainHealth -DomainName 'evotec.pl'

$T1 = Get-O365DomainDependencies -DomainName 'evotec.pl' -Type All -Verbose
$T1 | Format-Table