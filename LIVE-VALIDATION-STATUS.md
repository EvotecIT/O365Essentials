# Live Validation Status

Last updated: 2026-04-02

This note captures the current live-validation state of the higher-value internal/private
admin-center endpoints imported from M365Internals. It is meant to preserve the proven
tenant results without requiring another broad validation sweep.

## Live-Verified Commands

- `Get-O365TenantRelationship`
- `Get-O365OrgPeopleSettings`
- `Get-O365OrgIntegratedApps`
- `Get-O365OrgBrandCenter`
- `Get-O365OrgMicrosoftEdge`
- `Get-O365OrgBackup`
- `Get-O365ContentUnderstanding`
- `Get-O365AgentSettings`
- `Get-O365AgentTools`
- `Get-O365AgentOverview`
- `Get-O365SearchIntelligenceAdvanced`
  - Healthy for the important routes
  - `Qnas` remains optional and tenant-specific
- `Get-O365CopilotConnectors -Name Summary`
- `Get-O365OrgVivaSettings`
  - `Modules` healthy
  - `Roles` healthy
  - `AccountSkus` healthy
- `Get-O365PayAsYouGoService`
  - Core read surfaces are healthy
  - `Telemetry` is correctly modeled as a write-only observed route

## Added But Still Requiring Broader Live Verification

- `Get-O365CopilotOverview`
- `Get-O365CopilotSettings`
- `Get-O365CopilotBillingUsage`
- `Get-O365CopilotConnectors`
  - Only `Summary` is explicitly live-verified today
  - Other routes still need broader tenant validation
- `Get-O365OrgVivaSettings`
  - `GlintClient` remains the only known unresolved route
- `Get-O365OrgMicrosoftEdgeSiteLists`
  - Included under the broader Edge work, but still worth a standalone targeted rerun if we revisit validation

## Support And Validation Commands Added

- `Get-O365InternalApiHealth`
- `Get-O365InternalApiFinding`
- `Get-O365InternalApiValidationReport`
- `Get-O365UnavailableResult`
- `Get-O365UnavailableSummary`
- `Test-O365UnavailableResult`

## Known Exceptions

- `Get-O365OrgVivaSettings -Name GlintClient`
  - Still unavailable
  - Live browser validation against the same endpoint returned HTTP 500 for this tenant
  - Current assessment: service-side or tenant-side issue, not a replay mismatch

- `Get-O365PayAsYouGoService -Name Telemetry`
  - Not a readable data endpoint
  - Confirmed as a write-only telemetry/event route returning HTTP 204 in the live portal
  - Modeled in the module as observed write-only metadata instead of a failed read

## Replay Notes

- Token-only auth is enough for many of the imported surfaces.
- The more portal-sensitive routes now work through the hidden portal replay path inside
  `Connect-O365Admin` and `Invoke-O365Admin`.
- Search, Agent Overview, and Copilot Connectors Summary were all confirmed live after the
  portal replay alignment fixes.

## Current Recommendation

- Treat the value-focused import work as largely complete.
- Prefer targeted live checks for single routes over another broad tenant-wide validation
  sweep unless a specific regression appears.
- Keep `GlintClient` as the only clearly known unresolved live-validation exception for now.
