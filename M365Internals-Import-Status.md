# M365Internals Import Status

Last updated: 2026-04-02

This file tracks the current state of the value-focused internal/private API import work
 from M365Internals into O365Essentials.

## New Public Commands Added

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

## Live-Verified As Working

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
  - `Qnas` still optional and tenant-specific
- `Get-O365CopilotConnectors -Name Summary`
- `Get-O365OrgVivaSettings -Name Modules`
- `Get-O365OrgVivaSettings -Name Roles`
- `Get-O365OrgVivaSettings -Name AccountSkus`
- `Get-O365PayAsYouGoService`
  - Read surfaces validated
  - `Telemetry` intentionally modeled as write-only observed metadata

## Added But Still Needing Broader Live Verification

- `Get-O365CopilotOverview`
- `Get-O365CopilotSettings`
- `Get-O365CopilotBillingUsage`
- `Get-O365CopilotConnectors`
  - Beyond `Summary`
- `Get-O365OrgMicrosoftEdgeSiteLists`
  - Broader Edge path was validated, but this standalone route still deserves a direct rerun

## Known Exception

- `Get-O365OrgVivaSettings -Name GlintClient`
  - Live browser validation for the same endpoint returned HTTP 500
  - Current assessment: service-side or tenant-side issue, not an O365Essentials replay bug

## Plumbing Added To Keep UX Stable

- Hidden portal replay support stays behind `Connect-O365Admin` and `Invoke-O365Admin`
- Portal attachment/session helpers were moved under `Private`
- End users should continue to use the same public connect flow

## Recommendation

- Treat the main value-focused import as complete enough for PR review
- Use targeted live reruns for specific Copilot routes only if needed
- Do not spend more time on broad auth-heavy sweeps unless a real regression appears
