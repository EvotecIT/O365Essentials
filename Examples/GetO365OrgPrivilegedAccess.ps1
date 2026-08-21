Import-Module .\O365Essentials.psd1 -Force

# Connect-O365Admin uses an interactive OAuth flow supported by Windows PowerShell 5.1
# and PowerShell 7. Use -UseWam on PowerShell 7.4 or newer when broker sign-in is preferred.
$null = Connect-O365Admin -Verbose

Get-O365OrgPrivilegedAccess

# AdminGroup is the primary SMTP address of a mail-enabled security group.
# Review the proposed change before removing -WhatIf.
Set-O365OrgPrivilegedAccess -TenantLockBoxEnabled $true -AdminGroup 'pamapprovers@contoso.com' -WhatIf
