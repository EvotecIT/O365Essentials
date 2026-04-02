Import-Module .\O365Essentials.psd1 -Force

$null = Connect-O365Admin -Verbose

Get-O365TenantRelationship -Verbose
Get-O365TenantRelationship -Name Tenants -Verbose
