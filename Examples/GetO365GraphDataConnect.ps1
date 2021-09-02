Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials

Get-O365OrgGraphDataConnect | Format-Table

# THE EMAIL ADDRESS for GROUP MUST EXISTS - if not you will break the API (which you can fix with force)
Set-O365OrgGraphDataConnect -ServiceEnabled $true -WhatIf
Set-O365OrgGraphDataConnect -ServiceEnabled $false -TenantLockBoxApproverGroup 'graph@evotec.pl' -Verbose -Force -WhatIf
Set-O365OrgGraphDataConnect -ServiceEnabled $true -TenantLockBoxApproverGroup 'test@evotec.pl' -Verbose -Force -WhatIf
Set-O365OrgGraphDataConnect -ServiceEnabled $false -WhatIf