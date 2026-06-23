Import-Module .\O365Essentials.psd1 -Force

$TenantId = '00000000-0000-0000-0000-000000000000'
$Credential = Get-Credential -UserName 'admin@contoso.com' -Message 'Enter the account to use as the WAM login hint'

$Headers = Connect-O365Admin -UseWam -Credential $Credential -Tenant $TenantId -ForceRefresh -GraphScope 'Policy.Read.All' -Verbose

Get-O365AzureConditionalAccessLocation -Headers $Headers -Verbose
