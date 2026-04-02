$Configuration = Connect-O365Admin

Get-O365OrgMicrosoftEdge -Headers $Configuration
Get-O365OrgMicrosoftEdge -Headers $Configuration -Name DeviceCount
Get-O365OrgMicrosoftEdgeSiteLists -Headers $Configuration -Name Notifications
