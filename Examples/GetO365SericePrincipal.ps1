Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365ServicePrincipal | Format-Table
Get-O365ServicePrincipal -Id '2f4f683a-7adf-41c4-8ca5-58ef1991b17d' | Format-Table
Get-O365ServicePrincipal -ServicePrincipalType Legacy | Format-Table