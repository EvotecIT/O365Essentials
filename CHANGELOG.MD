# O365Essentials Release History

## 0.0.15 - 2024.12.17
* Update Set-O365OrgForms.ps1 added ResponderEditResponse parameter by @SaschaLac in https://github.com/EvotecIT/O365Essentials/pull/32
* Added help to 146 functions by @neztach in https://github.com/EvotecIT/O365Essentials/pull/30
* Added `Get-O365CopilotPin`

### New Contributors
* @SaschaLac made their first contribution in https://github.com/EvotecIT/O365Essentials/pull/32
* @neztach made their first contribution in https://github.com/EvotecIT/O365Essentials/pull/30

**Full Changelog**: https://github.com/EvotecIT/O365Essentials/compare/v0.0.14...v0.0.15

## 0.0.14 - 2024.05.28
- Downgraded `Az.Accounts` to minimal `2.12.1`. `3.0.0` is kind of broken and PS 5 has issues, you can still use newest one
- Added `Get-O365OrgSendEmailNotification` and `Set-O365OrgSendEmailNotification` which allows configuring [SenderFromAddressSettings](https://admin.microsoft.com/Adminportal/Home?#/Settings/OrganizationProfile/:/Settings/L1/SendFromAddressSettings) for email notifications
- Fixed `Get-O365OrgUserConsentApps` and `Set-O365OrgUserConsentApps` - but it changes how things work, so requires code changes. This configures [User consent settings](https://portal.azure.com/#view/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/~/UserSettings). You should probably utilize native Graph `https://graph.microsoft.com/v1.0/policies/authorizationPolicy` instead, but for the sake of fixing it, it's here.

## 0.0.13
- Docs updates / Bump dependencies

## 0.0.12 - 2023.09.19
- Add `Get-O365OrgAccountLinking` and `Set-O365OrgAccountLinking` to manage "Users who connect their Azure AD account with their MSA account can earn rewards points when they search on Bing. User searches are never shared."
- Added `Get-O365OrgAdoptionScore`, `Get-O365OrgAdoptionScoreConfig` and `Set-O365OrgAdoptionScore` to manage Microsoft 365 Adoption Score

## 0.0.11 - 2023.07.18
  - Added `Get-O365OrgMicrosoftEdgeSiteLists`
  - Added `Get-O365OrgVivaLearning` and `Set-O365OrgVivaLearning`
  - Added `Get-O365AzureExternalCollaborationRestrictions`
  - Added `Set-O365AzureExternalCollaborationRestrictions`
  - Added `Disconnect-O365Admin`

## 0.0.10 - 2021.10.11
  - Added `Get-O365AzureProperties` from URL https://aad.portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Properties
  - Added `Set-O365AzureProperties` from URL https://aad.portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Properties
  - Added `Get-O365AzurePropertiesSecurity` from URL https://aad.portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Properties
  - Added `Set-O365AzurePropertiesSecurity` from URL https://aad.portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Properties
## 0.0.9 - 2021.09.23
  - Improved some commands
## 0.0.8 - 2021.09.20
  - Added more commands
  - Improved some commands
  - Cleaned up some duplicates
## 0.0.7 - 2021.09.15
  - Added more commands
  - Improved some commands
## 0.0.6 - 2021.09.13
  - Added more commands
## 0.0.5 - 2021.09.10
  - Added new cmdlets
  - Fixes some bugs
## 0.0.4 - 2021.09.10
  - Something went wrong during publish of 0.0.3 - this release fixes it
## 0.0.3 - 2021.09.10
  - Renamed most of commands to be more descriptive
  - Added new commands
  - Fixed some bugs
  - Fixes support for PowerShell 5.1
## 0.0.2 - 2021.08.27
  - Added more commands
## 0.0.1 - 2021.08.19
  - First version