---
title: "Review group naming policy settings"
description: "Use O365Essentials to inspect Microsoft 365 group naming policy settings before making changes."
layout: docs
---

This pattern is useful when you need to review the current naming policy before deciding whether to apply a change.

It is adapted from `Examples/GetO365AzureGroupNaming.ps1`.

## Example

```powershell
Import-Module O365Essentials

Connect-O365Admin -Verbose

Get-O365AzureGroupNamingPolicy -Verbose | Format-Table

Set-O365AzureGroupNamingPolicy `
    -Prefix 'M365' `
    -Suffix 'Department', 'Region' `
    -Verbose
```

## What this demonstrates

- reviewing the current group naming policy
- applying an intentional naming policy change after review
- avoiding tenant-specific suffix values

## Source

- [GetO365AzureGroupNaming.ps1](https://github.com/EvotecIT/O365Essentials/blob/master/Examples/GetO365AzureGroupNaming.ps1)
