Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

$CA = Get-O365AzureConditionalAccess
$CA | Format-Table
#$CA | Format-List


$CA = Get-O365AzureConditionalAccess -Details
$CA | Format-Table


#Get-O365AzureConditionalAccessPolicy -PolicyID '7eac83fb-856b-45bf-9896-4fc78ea686f1'
Get-O365AzureConditionalAccessPolicy -PolicyName 'Guest Access Policy 1'