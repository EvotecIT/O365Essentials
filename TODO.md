**Scope**
- Add Teams Admin support mirroring GUI calls to `teams.microsoft.com` and prep for Substrate (AdminAppCatalog) reads.
- Keep the same Connect/Invoke pattern: auto-acquire tokens, route headers by host, and expose simple Get/Set wrappers.

**What’s Implemented**
- Teams token flow: `Connect-O365Admin` now acquires a token for `api.spaces.skype.com` and caches `HeadersTeams`.
- Host routing: `Invoke-O365Admin` selects headers for `teams.microsoft.com` and `substrate.office.com`.
- Teams endpoints:
  - `Get-O365TeamsTenantWideAppsSettings`
  - `Set-O365TeamsTenantWideAppsSettings` (partial-by-default; `-Full` optional)
  - Partial PUT includes `appSettingsList: []` by default to match GUI behavior and avoid 400s.
- Substrate bootstrap:
  - Persistent config at `%APPDATA%\O365Essentials\config.json` with DPAPI-protected secrets (Windows).
  - `Set-O365SubstrateAuth` to capture a one-time Substrate refresh token using the UI’s client ID via device login.
  - `Connect-O365Admin` will silently reuse the saved Substrate refresh token on future runs.
- Examples:
  - `Examples/GetO365TeamsTenantWideAppsSettings.ps1`
  - `Examples/GetO365UnifiedAppsSettings.ps1`

**New Commands**
- `Get-O365TeamsTenantWideAppsSettings` — GET Teams tenant-wide app settings.
- `Set-O365TeamsTenantWideAppsSettings` — PUT updates; default is partial; `-Full` sends merged complete body.
- `Get-O365UnifiedAppsSettings` — GET Substrate unified apps (works once Substrate token captured).
- `Set-O365SubstrateAuth` — one-time capture of Substrate refresh token for the Teams Admin UI client.

**How Auth Works (Today)**
- `Connect-O365Admin` acquires Graph → uses refresh to get: admin.microsoft.com, api.spaces.skype.com (Teams), Azure, ARM.
- Teams requests automatically use `HeadersTeams` (adds Origin/Referer, cache flags).
- Substrate: first-party resource; default client cannot mint tokens (AADSTS65002). Use `Set-O365SubstrateAuth` with the UI’s `client_id` once; we then reuse that refresh token to mint Substrate tokens.

**Quick Use**
- Connect: `Connect-O365Admin -Verbose` (or `-Device` on servers/remoting).
- Read Teams: `Get-O365TeamsTenantWideAppsSettings -Region 'emea'`.
- Partial update (default):
  - `Set-O365TeamsTenantWideAppsSettings -Region 'emea' -IsSideloadedAppsInteractionEnabled:$true -IsLicenseBasedPinnedAppsEnabled:$true -WhatIf`
- Full update:
  - `Set-O365TeamsTenantWideAppsSettings -Region 'emea' -Full -IsAppsEnabled $true -IsExternalAppsEnabledByDefault $true -WhatIf`
- Capture Substrate once:
  - `Set-O365SubstrateAuth -SubstrateClientId '<UI appid>' -Verbose`
- Read Substrate (after capture): `Get-O365UnifiedAppsSettings -Verbose`.

**What To Test (Checklist)**
- Teams GET returns the expected fields for your tenant/region.
- Partial PUT succeeds (200) and persists:
  - Toggle booleans (e.g., `IsSideloadedAppsInteractionEnabled`, `IsLicenseBasedPinnedAppsEnabled`).
  - Verify with subsequent GET.
- Full PUT works when partial fails (some tenants may require full body).
- `appSettingsList` handling:
  - Partial default includes `[]` unless provided; verify no 400.
  - Full merges existing list unless overridden.
- Region parameter:
  - Confirm `-Region` (emea/amer/apac) matches your tenant. Add auto-detect later (see TODO).
- Header routing:
  - `Invoke-O365Admin` picks Teams headers for `teams.microsoft.com`.
- Substrate capture flow:
  - Run `Set-O365SubstrateAuth` with the Teams Admin UI `client_id` (from browser token appid).
  - Confirm `Connect-O365Admin` now fetches Substrate token and `Get-O365UnifiedAppsSettings` returns 200.
- Caching/expiry:
  - Reuse `Connect-O365Admin` headers across multiple calls; auto-refresh works before expiry.
- Safety switches:
  - `-WhatIf` respected on setters; no changes applied.

**Known Limitations**
- Substrate requires the first‑party Teams Admin UI client to mint tokens; generic client (04b0… Azure PowerShell) is not preauthorized (AADSTS65002).
- Teams region discovery is manual for now (default `emea`).
- GUI may lag behind API changes; the UI also reads Substrate unified apps, which may cause apparent mismatches.

**Next Up (TODOs)**
- Auto-detect Teams region (probe known segments and cache the first 200 OK).
- Expose `-SubstrateClientId` on `Connect-O365Admin` (optional) to override the persisted value at runtime.
- Implement `Set-O365UnifiedAppsSettings` once we capture the exact write endpoint/payload from the GUI.
- Add a compare helper to show Teams vs Substrate state side-by-side.
- Make `x-ms-forest` dynamic (map from region/tenant) and configurable.
- Add a small helper to paste a JWT and extract/store `appid` for `Set-O365SubstrateAuth`.
- README update: new commands, auth model, risks, and examples.
- Version bump once stabilized and tests pass.

**M365Internals Import Plan**
- See `M365Internals-Import-Backlog.md` for the staged import plan covering Agents, Copilot, Search, People, Tenant Relationships, Backup, and related admin-center-only APIs.
- Start with the "First Implementation Slice" in that file before pulling in the more portal-context-sensitive Copilot and Search routes.
- See `LIVE-VALIDATION-STATUS.md` for the latest live-validated endpoint status and the current known exception list.

**Debug Tips**
- Use `-Verbose` to see which token audiences are requested and which headers are routed.
- Decode tokens: `ConvertFrom-JSONWebToken -Token $token` and check `aud`, `appid`, `tid`.
- Capture GUI calls with devtools; mirror payload/headers if an endpoint is picky.

**References (Files)**
- Public/Connect-O365Admin.ps1
- Public/Invoke-O365Admin.ps1
- Public/Get-O365TeamsTenantWideAppsSettings.ps1
- Public/Set-O365TeamsTenantWideAppsSettings.ps1
- Public/Get-O365UnifiedAppsSettings.ps1
- Public/Set-O365SubstrateAuth.ps1
- Private/Config.O365Essentials.ps1
- Examples/GetO365TeamsTenantWideAppsSettings.ps1
- Examples/GetO365UnifiedAppsSettings.ps1
