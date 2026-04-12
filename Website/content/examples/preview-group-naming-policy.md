---
title: "Preview group naming policy changes"
description: "Use O365Essentials to inspect and preview Microsoft 365 group naming policy changes."
layout: docs
---

This pattern is useful when you need to review the current naming policy and model a change without applying it.

It is adapted from `Examples/GetO365AzureGroupNaming.ps1`.

## Example

```powershell
Import-Module O365Essentials

Connect-O365Admin -Verbose

Get-O365AzureGroupNamingPolicy -Verbose | Format-Table

Set-O365AzureGroupNamingPolicy `
    -Prefix 'M365' `
    -Suffix 'Department', 'Region' `
    -Verbose `
    -WhatIf
```

## What this demonstrates

- reviewing the current group naming policy
- modeling a naming change with `-WhatIf`
- avoiding tenant-specific suffix values

## Source

- [GetO365AzureGroupNaming.ps1](https://github.com/EvotecIT/O365Essentials/blob/master/Examples/GetO365AzureGroupNaming.ps1)
