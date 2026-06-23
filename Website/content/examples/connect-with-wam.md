---
title: "Connect with WAM and explicit Graph scopes"
description: "Use O365Essentials with Windows Web Account Manager for MFA-aware sign-in and Graph scope consent."
layout: docs
---

This pattern is useful when MFA is required, when the wrong cached Windows account is selected, or when a Graph command needs a delegated scope that is not already present in the token cache.

It is adapted from `Examples/ConnectO365AdminWam.ps1`.

## Example

```powershell
Import-Module O365Essentials

$TenantId = '00000000-0000-0000-0000-000000000000'
$Credential = Get-Credential -UserName 'admin@contoso.com' -Message 'Enter the account to use as the WAM login hint'

$Headers = Connect-O365Admin `
    -UseWam `
    -Credential $Credential `
    -Tenant $TenantId `
    -ForceRefresh `
    -GraphScope 'Policy.Read.All' `
    -Verbose

Get-O365AzureConditionalAccessLocation -Headers $Headers -Verbose
```

## What this demonstrates

- using WAM instead of legacy OAuth cache seeding
- using a credential username as a WAM login hint without sending the password to Graph
- forcing the account picker when the Windows cache picked the wrong identity
- requesting the Graph scope required by the command

## Source

- [ConnectO365AdminWam.ps1](https://github.com/EvotecIT/O365Essentials/blob/master/Examples/ConnectO365AdminWam.ps1)
