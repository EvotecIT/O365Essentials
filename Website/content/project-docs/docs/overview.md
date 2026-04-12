---
title: "O365Essentials Overview"
description: "When to use O365Essentials and what it covers."
layout: docs
---

Use O365Essentials when Microsoft 365 tenant settings need to be inspected or adjusted from PowerShell and the supported Graph surface does not cover the setting cleanly.

The module combines Microsoft Graph calls with admin portal and internal API calls. That makes it useful for operational work, but it also means changes should be tested carefully because Microsoft can alter those internal routes.

## Common tasks

- Review administrative roles and role membership.
- Inspect Conditional Access and tenant-wide settings.
- Preview group naming or enterprise application settings with `-WhatIf`.
- Keep authentication and tenant targeting explicit.
