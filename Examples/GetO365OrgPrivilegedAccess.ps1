Import-Module .\O365Essentials.psd1 -Force

# Use WAM for an MFA-aware interactive sign-in.
$Credential = Get-Credential -UserName 'admin@contoso.com' -Message 'Enter the account to use as the WAM login hint'
$null = Connect-O365Admin -UseWam -Credential $Credential -ForceRefresh -Verbose

Get-O365OrgPrivilegedAccess

# AdminGroup is the primary SMTP address of a mail-enabled security group.
# Review the proposed change before removing -WhatIf.
Set-O365OrgPrivilegedAccess -TenantLockBoxEnabled $true -AdminGroup 'pamapprovers@contoso.com' -WhatIf
