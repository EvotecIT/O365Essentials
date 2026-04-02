# Summary

This PR closes the most valuable internal/private API gaps between O365Essentials and
M365Internals while keeping the public user experience centered on `Connect-O365Admin`.

It adds new admin-center readers for Agents, Copilot, Search, People, Integrated Apps,
Tenant Relationships, Backup, Content Understanding, Edge, Brand Center, Viva, and
pay-as-you-go validation/reporting helpers. It also introduces the hidden portal replay
plumbing required for the newer `admin.cloud.microsoft` routes without exposing extra
public connect commands.

# What Changed

## New public commands

- `Get-O365AgentOverview`
- `Get-O365AgentSettings`
- `Get-O365AgentTools`
- `Get-O365ContentUnderstanding`
- `Get-O365CopilotBillingUsage`
- `Get-O365CopilotConnectors`
- `Get-O365CopilotOverview`
- `Get-O365CopilotSettings`
- `Get-O365InternalApiFinding`
- `Get-O365InternalApiHealth`
- `Get-O365InternalApiValidationReport`
- `Get-O365OrgBackup`
- `Get-O365OrgBrandCenter`
- `Get-O365OrgIntegratedApps`
- `Get-O365OrgMicrosoftEdge`
- `Get-O365OrgPeopleSettings`
- `Get-O365OrgVivaSettings`
- `Get-O365PayAsYouGoService`
- `Get-O365SearchIntelligenceAdvanced`
- `Get-O365TenantRelationship`
- `Get-O365UnavailableResult`
- `Get-O365UnavailableSummary`
- `Test-O365UnavailableResult`

## Connection and replay work

- Added hidden portal replay support for `admin.cloud.microsoft` routes
- Kept `Connect-O365Admin` as the main public entry point
- Moved portal attachment/session helpers under `Private` so publisher rebuilds do not re-export them
- Improved unavailable-result handling and validation reporting for tenant-specific or portal-sensitive routes

## Live replay and endpoint alignment

- Aligned key replay headers and request shapes with live browser traffic
- Fixed Search replay so the important routes return data
- Fixed Agent Overview replay, including browser-valid `200 null` offer responses
- Fixed Copilot connector summary replay
- Updated Viva to the live `admin.cloud.microsoft` routes and reclassified Glint as a service-side issue when the browser itself returns HTTP 500
- Reclassified pay-as-you-go telemetry as a write-only observed route instead of a failed read

# Live Validation Status

## Verified working live

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
  - Important routes healthy
  - `Qnas` remains optional and tenant-specific
- `Get-O365CopilotConnectors -Name Summary`
- `Get-O365OrgVivaSettings -Name Modules`
- `Get-O365OrgVivaSettings -Name Roles`
- `Get-O365OrgVivaSettings -Name AccountSkus`
- `Get-O365PayAsYouGoService`
  - Read surfaces validated
  - `Telemetry` intentionally modeled as write-only metadata

## Added but still needing broader live verification

- `Get-O365CopilotOverview`
- `Get-O365CopilotSettings`
- `Get-O365CopilotBillingUsage`
- `Get-O365CopilotConnectors`
  - Non-summary routes
- `Get-O365OrgMicrosoftEdgeSiteLists`
  - Worth a standalone targeted rerun

## Known exception

- `Get-O365OrgVivaSettings -Name GlintClient`
  - Live browser validation returned HTTP 500 for the same endpoint
  - Current assessment: tenant-side or service-side issue, not a replay mismatch

# Testing

## Automated

- Focused Pester coverage added for the new command families and replay plumbing
- Validation/reporting helper tests are green
- Latest focused rerun for Viva status handling: `5/5` passing

## Live validation

- Targeted live validation was performed against a real tenant on 2026-04-02
- Validation emphasized correctness over broad coverage and avoided treating optional or write-only routes as hard failures
- Current live status is captured in `LIVE-VALIDATION-STATUS.md`

# Risks / Follow-up

- The remaining meaningful follow-up is targeted validation for the broader Copilot surfaces
- `GlintClient` should stay treated as a known exception unless the portal itself starts succeeding
- Avoid broad auth-heavy validation sweeps unless a specific regression appears; targeted reruns have been much more reliable
