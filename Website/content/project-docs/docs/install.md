---
title: "Install O365Essentials"
description: "Install O365Essentials from PowerShell Gallery."
layout: docs
---

Install O365Essentials from PowerShell Gallery:

```powershell
Install-Module -Name O365Essentials -Scope CurrentUser -AllowClobber
```

Import the module and connect interactively:

```powershell
Import-Module O365Essentials
Connect-O365Admin -Verbose
```

Use WAM when the tenant requires MFA or Windows needs to show the account picker:

```powershell
$Credential = Get-Credential -UserName 'admin@contoso.com'
Connect-O365Admin -UseWam -Credential $Credential -Tenant '00000000-0000-0000-0000-000000000000' -ForceRefresh -Verbose
```

Prefer PowerShell 7 or newer so REST errors are easier to read.
