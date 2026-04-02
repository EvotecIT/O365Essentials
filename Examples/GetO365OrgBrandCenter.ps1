$Configuration = Connect-O365Admin

Get-O365OrgBrandCenter -Headers $Configuration
Get-O365OrgBrandCenter -Headers $Configuration -Name SiteUrl
