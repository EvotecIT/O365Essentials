---
title: "Review admin role membership"
description: "Use O365Essentials to review selected Microsoft 365 administrative role members."
layout: docs
---

This pattern is useful when you want a quick tenant admin review without changing settings.

It is adapted from `Examples/GetO365ADRoles.ps1`.

## Example

```powershell
Import-Module O365Essentials

Connect-O365Admin -Verbose

$roles = Get-O365AzureADRolesMember -RoleName 'Global Administrator', 'Global Reader', 'Security Reader'

$roles.'Global Administrator' | Format-Table
$roles.'Global Reader' | Format-Table
$roles.'Security Reader' | Format-Table
```

## What this demonstrates

- connecting interactively
- selecting a small set of high-value roles
- keeping the command read-only

## Source

- [GetO365ADRoles.ps1](https://github.com/EvotecIT/O365Essentials/blob/master/Examples/GetO365ADRoles.ps1)
