# M365Internals Import Backlog

This document turns the M365Internals comparison into an implementation backlog for `O365Essentials`.

The goal is to add high-value Microsoft 365 admin center coverage that:

- uses internal or private APIs not already well-covered by Graph
- brings clear value to administrators
- avoids low-value portal bootstrap plumbing unless it unlocks real admin scenarios

## Delivery Rules

- Keep the current `Connect-O365Admin` plus `Invoke-O365Admin` model.
- Prefer a small number of parameterized cmdlets over a large number of one-endpoint wrappers when the endpoints belong to one admin surface.
- Add `Examples\*.ps1` and `Tests\*.ps1` for every new public cmdlet.
- Reuse current `O365Essentials` naming where possible:
  - `Org` prefix for organization settings
  - `Copilot` prefix for Copilot-only surfaces
  - `SearchIntelligence` prefix for Search admin features
  - `Agent` prefix for Agents admin center features

## Foundation Work

These items should land before the harder Copilot, Search, and portal-context-sensitive cmdlets.

| Priority | File | Type | Purpose | Notes |
| --- | --- | --- | --- | --- |
| P0 | `Private\Get-O365PortalContextHeaders.ps1` | New | Build reusable admin portal context headers for routes that require `x-adminapp-request`, `Referer`, `x-ms-mac-*`, or `AjaxSessionKey`. | Model after `M365Internals\internal\functions\Get-M365PortalContextHeaders.ps1`. |
| P0 | `Public\Invoke-O365Admin.ps1` | Update | Allow callers to merge extra portal headers cleanly instead of hardcoding them in each cmdlet. | Add something small like `-AdditionalHeaders` or `-Context`. |
| P1 | `Private\Invoke-O365PortalBootstrap.ps1` | Deferred new helper | Replay post-login portal bootstrap only if we confirm specific routes fail without it. | Model after `M365Internals\internal\functions\Invoke-M365PortalPostLandingBootstrap.ps1`. |

## Phase 1 - Best Easy Wins

These are the first cmdlets to implement. They add clear value and should be less sensitive to full portal bootstrap behavior.

### 1. Tenant Relationships

| Item | Value |
| --- | --- |
| Public file | `Public\Get-O365TenantRelationship.ps1` |
| Example | `Examples\GetO365TenantRelationship.ps1` |
| Test | `Tests\Get-O365TenantRelationship.Tests.ps1` |
| Source | `M365Internals\functions\Get-M365AdminTenantRelationship.ps1` |
| Suggested shape | `Get-O365TenantRelationship [-Name MultiTenantOrganization|Tenants|RemovedTenants|UserSyncAppOutboundDetails|All]` |
| Key routes | `/admin/api/tenantRelationships/multiTenantOrganization`, `/admin/api/tenantRelationships/multiTenantOrganization/tenants`, `/admin/api/tenantRelationships/multiTenantOrganization/removedTenants`, `/admin/api/tenantRelationships/userSyncApps/outboundDetails` |
| Why first | High admin value, clearly internal, very little overlap with current module. |

### 2. People Settings

| Item | Value |
| --- | --- |
| Public file | `Public\Get-O365OrgPeopleSettings.ps1` |
| Example | `Examples\GetO365OrgPeopleSettings.ps1` |
| Test | `Tests\Get-O365OrgPeopleSettings.Tests.ps1` |
| Source | `M365Internals\functions\Get-M365AdminPeopleSetting.ps1` |
| Suggested shape | `Get-O365OrgPeopleSettings [-Name ProfileCardProperties|ConnectorProperties|NamePronunciation|Pronouns|All]` |
| Key routes | `/fd/peopleadminservice/{tenantId}/profilecard/properties`, `/fd/peopleadminservice/{tenantId}/connectorProperties`, `/fd/peopleadminservice/{tenantId}/settings/namePronunciation`, `/fd/peopleadminservice/{tenantId}/settings/pronouns` |
| Why first | Strong admin-center-only coverage with clear value and low duplication risk. |

### 3. Integrated Apps

| Item | Value |
| --- | --- |
| Public file | `Public\Get-O365OrgIntegratedApps.ps1` |
| Example | `Examples\GetO365OrgIntegratedApps.ps1` |
| Test | `Tests\Get-O365OrgIntegratedApps.Tests.ps1` |
| Source | `M365Internals\functions\Get-M365AdminIntegratedAppSetting.ps1` |
| Suggested shape | `Get-O365OrgIntegratedApps [-Name Settings|AppCatalog|AvailableApps|ActionableApps|PopularAppRecommendations|All]` |
| Key routes | `/fd/addins/api/v2/settings`, `/fd/addins/api/apps`, `/fd/addins/api/availableApps`, `/fd/addins/api/actionableApps`, `/fd/addins/api/recommendations/appRecommendations` |
| Why first | Valuable private APIs with little current overlap except `Get-O365UnifiedAppsSettings`. |

### 4. Agent Settings

| Item | Value |
| --- | --- |
| Public file | `Public\Get-O365AgentSettings.ps1` |
| Example | `Examples\GetO365AgentSettings.ps1` |
| Test | `Tests\Get-O365AgentSettings.Tests.ps1` |
| Source | `M365Internals\functions\Get-M365AdminAgentSetting.ps1` |
| Suggested shape | `Get-O365AgentSettings [-Name AllowedAgentTypes|Sharing|Templates|UserAccess|All]` |
| Key routes | `/fd/addins/api/v2/settings`, `/admin/api/agenttemplates/getagenttemplates`, `/admin/api/agenttemplates/getpolicies`, `/admin/api/tenant/billingAccountsWithShell`, `/admin/api/tenant/customviewfilterdefaults`, `/admin/api/users/getuserroles`, `/_api/SPOInternalUseOnly.TenantAdminSettings/AutoQuotaEnabled` |
| Why first | One of the biggest current gaps and a very current admin experience. |

### 5. Agent Tools

| Item | Value |
| --- | --- |
| Public file | `Public\Get-O365AgentTools.ps1` |
| Example | `Examples\GetO365AgentTools.ps1` |
| Test | `Tests\Get-O365AgentTools.Tests.ps1` |
| Source | `M365Internals\functions\Get-M365AdminAgentTool.ps1` |
| Suggested shape | `Get-O365AgentTools [-Name McpServers|All]` |
| Key routes | `/admin/api/agentssettings/mcpservers` |
| Why first | Small, useful, and clearly differentiated from existing module features. |

### 6. Agent Overview

| Item | Value |
| --- | --- |
| Public file | `Public\Get-O365AgentOverview.ps1` |
| Example | `Examples\GetO365AgentOverview.ps1` |
| Test | `Tests\Get-O365AgentOverview.Tests.ps1` |
| Source | `M365Internals\functions\Get-M365AdminAgentOverview.ps1` |
| Suggested shape | `Get-O365AgentOverview [-Name Inventory|RiskyAgents|Usage|All]` |
| Key routes | `/fd/addins/api/agents`, `/fd/addins/api/actionableApps`, `/fd/addins/api/apps/insight`, `/admin/api/agentusers/metrics/agents/risky`, `/admin/api/reports/GetReportData`, `/admin/api/settings/company/frontier/access`, `/admin/api/users/products` |
| Why first | Gives the module an immediately valuable “Agents” story alongside `Get-O365AgentSettings`. |

## Phase 2 - High Value After Portal Context Work

These should be implemented after `Get-O365PortalContextHeaders` and `Invoke-O365Admin` support extra context headers.

### 7. Copilot Overview

| Item | Value |
| --- | --- |
| Public file | `Public\Get-O365CopilotOverview.ps1` |
| Example | `Examples\GetO365CopilotOverview.ps1` |
| Test | `Tests\Get-O365CopilotOverview.Tests.ps1` |
| Source | `M365Internals\functions\Get-M365AdminCopilotOverview.ps1` |
| Suggested shape | `Get-O365CopilotOverview [-Name Overview|Security|Usage|About|All]` |
| Key routes | `/admin/api/copilotsettings/settings`, `/admin/api/Copilot/getcopilotlicenseassignmentdate`, `/admin/api/reports/GetReportData`, `/admin/api/reports/GetSummaryDataV3`, `/fd/IDEAsKnowledgeService/api/odata/*`, `/fd/purview/*`, `/_api/v2.1/copilot/capacitypack/checkUsage` |
| Existing overlap | Keep current `Get-O365CopilotPin`; do not duplicate pin policy logic here. |

### 8. Copilot Settings

| Item | Value |
| --- | --- |
| Public file | `Public\Get-O365CopilotSettings.ps1` |
| Example | `Examples\GetO365CopilotSettings.ps1` |
| Test | `Tests\Get-O365CopilotSettings.Tests.ps1` |
| Source | `M365Internals\functions\Get-M365AdminCopilotSetting.ps1` |
| Suggested shape | `Get-O365CopilotSettings [-Name Settings|Dismissed|SecurityCopilotAuth|Recommendations|All]` |
| Key routes | `/admin/api/copilotsettings/settings/dismissed`, `/admin/api/copilotsettings/securitycopilot/auth`, `/admin/api/recommendations/m365/ccs`, `/_api/v2.1/billingPolicies`, `/fd/purview/*` |
| Why | Good companion to overview and useful for actual configuration state inspection. |

### 9. Copilot Connectors

| Item | Value |
| --- | --- |
| Public file | `Public\Get-O365CopilotConnectors.ps1` |
| Example | `Examples\GetO365CopilotConnectors.ps1` |
| Test | `Tests\Get-O365CopilotConnectors.Tests.ps1` |
| Source | `M365Internals\functions\Get-M365AdminCopilotConnector.ps1` |
| Suggested shape | `Get-O365CopilotConnectors [-Name Summary|Statistics|Connections|AdminUxOptions|GallerySettings|Gallery|YourConnections|All]` |
| Key routes | `/admin/api/searchadminapi/UDTConnectorsSummary`, `/fd/mssearchconnectors/v1.0/admin/connections/getStatistics`, `/fd/mssearchconnectors/v1.0/admin/connections/v2`, `/fd/mssearchconnectors/v1.0/admin/AdminUxOptionsV2/Connectors`, `/fd/ssms/api/v1.0/'MSS'/Collection('VT')/Settings(Path='',LogicalId='all')` |
| Existing overlap | Current search-intelligence coverage only partially overlaps this. |

### 10. Search Intelligence Advanced

| Item | Value |
| --- | --- |
| Public file | `Public\Get-O365SearchIntelligenceAdvanced.ps1` |
| Example | `Examples\GetO365SearchIntelligenceAdvanced.ps1` |
| Test | `Tests\Get-O365SearchIntelligenceAdvanced.Tests.ps1` |
| Source | `M365Internals\functions\Get-M365AdminSearchSetting.ps1` |
| Suggested shape | `Get-O365SearchIntelligenceAdvanced [-Name ConfigurationSettings|FirstRunExperience|ModernResultTypes|News|NewsIndustry|NewsMsbEnabled|NewsOptions|Pivots|Qnas|UdtConnectorsSummary]` |
| Key routes | `/admin/api/searchadminapi/ConfigurationSettings`, `/admin/api/searchadminapi/firstrunexperience/get`, `/admin/api/searchadminapi/modernResultTypes`, `/admin/api/searchadminapi/news/*`, `/admin/api/searchadminapi/Qnas`, `/admin/api/searchadminapi/UDTConnectorsSummary` |
| Existing overlap | Keep current simple cmdlets such as `Get-O365SearchIntelligenceBingConfigurations`, `Get-O365SearchIntelligenceMeetingInsights`, and `Get-O365SearchIntelligenceItemInsights`. |

### 11. Microsoft 365 Backup

| Item | Value |
| --- | --- |
| Public file | `Public\Get-O365OrgBackup.ps1` |
| Example | `Examples\GetO365OrgBackup.ps1` |
| Test | `Tests\Get-O365OrgBackup.Tests.ps1` |
| Source | `M365Internals\functions\Get-M365AdminMicrosoft365BackupSetting.ps1` |
| Suggested shape | `Get-O365OrgBackup [-Name AzureSubscriptions|AzureSubscriptionPermissions|BillingFeature|EnhancedRestoreFeature|EnhancedRestoreStatus|All]` |
| Key routes | `/admin/api/syntexbilling/azureSubscriptions`, `/admin/api/syntexbilling/azureSubscriptions/{id}/permissions`, `/_api/v2.1/billingFeatures('M365Backup')`, `/fd/enhancedRestorev2/v1/featureSetting` |
| Why | Strong differentiator, but more niche than Agents or Copilot. |

### 12. Content Understanding

| Item | Value |
| --- | --- |
| Public file | `Public\Get-O365ContentUnderstanding.ps1` |
| Example | `Examples\GetO365ContentUnderstanding.ps1` |
| Test | `Tests\Get-O365ContentUnderstanding.Tests.ps1` |
| Source | `M365Internals\functions\Get-M365AdminContentUnderstandingSetting.ps1` |
| Suggested shape | `Get-O365ContentUnderstanding [-Name Setting|Licensing|AutoFill|ESignature|ImageTagging|PlaybackTranscriptTranslation|TaxonomyTagging|BillingSettings|PowerAppsEnvironments]` |
| Key routes | `/admin/api/contentunderstanding/setting`, `/admin/api/contentunderstanding/licensing`, `/admin/api/contentunderstanding/autofillsetting`, `/admin/api/contentunderstanding/esignaturesettings`, `/admin/api/contentunderstanding/imagetaggingsetting`, `/admin/api/contentunderstanding/playbacktranscripttranslationsettings`, `/admin/api/contentunderstanding/taxonomytaggingsetting` |
| Why | Very internal and differentiated, but probably lower demand than the features above. |

## Phase 3 - Nice To Have

### 13. Brand Center

| Item | Value |
| --- | --- |
| Public file | `Public\Get-O365OrgBrandCenter.ps1` |
| Example | `Examples\GetO365OrgBrandCenter.ps1` |
| Test | `Tests\Get-O365OrgBrandCenter.Tests.ps1` |
| Source | `M365Internals\functions\Get-M365AdminBrandCenterSetting.ps1` |
| Suggested shape | `Get-O365OrgBrandCenter [-Name Configuration|SiteUrl|All]` |
| Key routes | `/_api/spo.tenant/GetBrandCenterConfiguration`, `/_api/GroupSiteManager/GetValidSiteUrlFromAlias` |
| Why later | Useful but less urgent than Agents, Copilot, Search, or Tenant Relationships. |

### 14. Viva Admin Metadata

| Item | Value |
| --- | --- |
| Public file | `Public\Get-O365OrgVivaMetadata.ps1` |
| Example | `Examples\GetO365OrgVivaMetadata.ps1` |
| Test | `Tests\Get-O365OrgVivaMetadata.Tests.ps1` |
| Source | `M365Internals\functions\Get-M365AdminVivaSetting.ps1` |
| Suggested shape | `Get-O365OrgVivaMetadata [-Name Modules|Roles|GlintClient|All]` |
| Key routes | `/admin/api/viva/modules`, `/admin/api/viva/roles`, `/admin/api/viva/glint/lookupclient` |
| Why later | Interesting metadata, but lower ROI than the top phases. |

### 15. Edge Advanced

| Item | Value |
| --- | --- |
| Public file | `Public\Get-O365OrgMicrosoftEdgeAdvanced.ps1` |
| Example | `Examples\GetO365OrgMicrosoftEdgeAdvanced.ps1` |
| Test | `Tests\Get-O365OrgMicrosoftEdgeAdvanced.Tests.ps1` |
| Source | `M365Internals\functions\Get-M365AdminEdgeSiteList.ps1`, `M365Internals\functions\Get-M365AdminMicrosoftEdgeSetting.ps1` |
| Suggested shape | `Get-O365OrgMicrosoftEdgeAdvanced [-Name SiteLists|Notifications|Policies|FeatureProfiles|ExtensionFeedback|All]` |
| Key routes | `/fd/edgeenterprisesitemanagement/api/v2/emiesitelists`, `/fd/edgeenterprisesitemanagement/api/v2/notifications`, `/fd/edgeenterpriseextensionsmanagement/api/policies`, `/fd/edgeenterpriseextensionsmanagement/api/featuremanagement/profiles`, `/fd/edgeenterpriseextensionsmanagement/api/extensions/extensionfeedback`, `/fd/OfficePolicyAdmin/v1.0/edge/policies` |
| Existing overlap | Current `Get-O365OrgMicrosoftEdgeSiteLists` only provides a shallow shard call. |

## Explicitly Deferred

These areas are intentionally not in the first implementation wave.

- `Get-M365AdminShellInfo`
- `Get-M365AdminHomeData`
- `Get-M365AdminNavigation`
- `Get-M365AdminFeature`
- generic bootstrap and recommendation plumbing that mainly helps reverse engineering rather than administrators

## Recommended Build Order

1. `Private\Get-O365PortalContextHeaders.ps1`
2. update `Public\Invoke-O365Admin.ps1`
3. `Public\Get-O365TenantRelationship.ps1`
4. `Public\Get-O365OrgPeopleSettings.ps1`
5. `Public\Get-O365OrgIntegratedApps.ps1`
6. `Public\Get-O365AgentSettings.ps1`
7. `Public\Get-O365AgentTools.ps1`
8. `Public\Get-O365AgentOverview.ps1`
9. `Public\Get-O365CopilotOverview.ps1`
10. `Public\Get-O365CopilotSettings.ps1`
11. `Public\Get-O365CopilotConnectors.ps1`
12. `Public\Get-O365SearchIntelligenceAdvanced.ps1`
13. `Public\Get-O365OrgBackup.ps1`
14. `Public\Get-O365ContentUnderstanding.ps1`
15. optional later: `BrandCenter`, `VivaMetadata`, `MicrosoftEdgeAdvanced`

## First Implementation Slice

If we want to start coding immediately, the best first slice is:

1. `Private\Get-O365PortalContextHeaders.ps1`
2. `Public\Get-O365TenantRelationship.ps1`
3. `Public\Get-O365OrgPeopleSettings.ps1`
4. `Public\Get-O365OrgIntegratedApps.ps1`
5. `Public\Get-O365AgentTools.ps1`

That gives us meaningful new coverage quickly without starting with the most fragile Copilot or Purview-backed routes.
