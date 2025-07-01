Import-Module .\O365Essentials.psd1 -Force

# This makes a connection to Office 365 tenant, using credentials
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$Headers = Connect-O365Admin -Verbose


$Uri = "https://compliance.microsoft.com/apiproxy/spo/admin/_api/SPO.Tenant/EnableAIPIntegration"
$Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Verbose
$Output

$Uri = "https://compliance.microsoft.com/apiproxy/psws/PolicyConfig"
$Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Verbose
$Output
