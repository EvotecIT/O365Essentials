Import-Module .\O365Essentials.psd1 -Force

$null = Connect-O365Admin -Verbose

Get-O365OrgBackup -Verbose
Get-O365OrgBackup -Name AzureSubscriptionPermissions -Verbose
Get-O365OrgBackup -Name EnhancedRestoreStatus -Verbose
