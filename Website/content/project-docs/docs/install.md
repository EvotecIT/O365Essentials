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

Prefer PowerShell 7 or newer so REST errors are easier to read.
