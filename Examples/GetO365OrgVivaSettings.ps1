$Configuration = Connect-O365Admin

Get-O365OrgVivaSettings -Headers $Configuration
Get-O365OrgVivaSettings -Headers $Configuration -Name Modules
Get-O365OrgVivaSettings -Headers $Configuration -Name AccountSkus
