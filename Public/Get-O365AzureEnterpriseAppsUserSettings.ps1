function Get-O365AzureEnterpriseAppsUserSettings {
    # https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/configure-user-consent?tabs=azure-portal
    # https://portal.azure.com/#blade/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/UserSettings
    # https://portal.azure.com/#blade/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/UserSettings/menuId/
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
    $Uri = 'https://main.iam.ad.ext.azure.com/api/EnterpriseApplications/UserSettings'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        if ($NoTranslation) {
            $Output
        } else {
            [PSCustomObject] @{
                UsersCanConsentAppsAccessingData = $Output.usersCanAllowAppsToAccessData
                UsersCanAddGalleryAppsToMyApp    = $Output.usersCanAddGalleryApps
                UsersCanOnlySeeO365AppsInPortal  = $Output.hideOffice365Apps
            }
        }
    }
}
<#
$CookieContainer = [System.Net.CookieContainer]::new()
$CookieContainer.MaxCookieSize = 8096

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36 Edg/93.0.961.38"
$session.Cookies = $CookieContainer
Invoke-WebRequest -UseBasicParsing -Uri "https://main.iam.ad.ext.azure.com/api/EnterpriseApplications/UserSettings" `
    -WebSession $session `
    -Headers @{
    "x-ms-client-session-id" = "820dcf17f6cd473d84759b81f8374113"
    "Accept-Language"        = "en"
    "Authorization"          = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiI3NDY1ODEzNi0xNGVjLTQ2MzAtYWQ5Yi0yNmUxNjBmZjBmYzYiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9jZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEvIiwiaWF0IjoxNjMwODQzNDE2LCJuYmYiOjE2MzA4NDM0MTYsImV4cCI6MTYzMDg0NzMxNiwiYWNyIjoiMSIsImFpbyI6IkFWUUFxLzhUQUFBQUhnV05Sa0IrbTY3VVRwQWpnSjlVcFpUdFl5QmpWNDR2RDhiMjlsK0h3akdxM0pYK0NGdi84Ynh3ZGl0ZnZ1a2JreVJiaS9IMkdGNVJNZTAveXJ4VlpEYjBvQ1ZDL2thTU5TT2lRQVJYTU04PSIsImFtciI6WyJyc2EiLCJtZmEiXSwiYXBwaWQiOiJjNDRiNDA4My0zYmIwLTQ5YzEtYjQ3ZC05NzRlNTNjYmRmM2MiLCJhcHBpZGFjciI6IjIiLCJkZXZpY2VpZCI6IjNhZTIyNzI2LWRmZDktNGFkNy1hODY1LWFhMmI1MWM2ZTBmZiIsImZhbWlseV9uYW1lIjoiS8WCeXMiLCJnaXZlbl9uYW1lIjoiUHJ6ZW15c8WCYXciLCJpcGFkZHIiOiI4OS43Ny4xMDIuMTciLCJuYW1lIjoiUHJ6ZW15c8WCYXcgS8WCeXMiLCJvaWQiOiJlNmE4ZjFjZi0wODc0LTQzMjMtYTEyZi0yYmY1MWJiNmRmZGQiLCJvbnByZW1fc2lkIjoiUy0xLTUtMjEtODUzNjE1OTg1LTI4NzA0NDUzMzktMzE2MzU5ODY1OS0xMTA1IiwicHVpZCI6IjEwMDMwMDAwOTQ0REI4NEQiLCJyaCI6IjAuQVM4QTluR3p6a1dIZGtpZ1FHbnkwUXFkR29OQVM4U3dPOEZKdEgyWFRsUEwzend2QUM4LiIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInN1YiI6ImVvU3lzNXlDNmJvWmQ5a21YRXVNSWl5YUxhX1g1VTdmSWZJck1DV0hORjQiLCJ0ZW5hbnRfcmVnaW9uX3Njb3BlIjoiRVUiLCJ0aWQiOiJjZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEiLCJ1bmlxdWVfbmFtZSI6InByemVteXNsYXcua2x5c0Bldm90ZWMucGwiLCJ1cG4iOiJwcnplbXlzbGF3LmtseXNAZXZvdGVjLnBsIiwidXRpIjoiSGJid2laanlMVS13TWVJOHRrTm9BQSIsInZlciI6IjEuMCIsIndpZHMiOlsiNjJlOTAzOTQtNjlmNS00MjM3LTkxOTAtMDEyMTc3MTQ1ZTEwIiwiYjc5ZmJmNGQtM2VmOS00Njg5LTgxNDMtNzZiMTk0ZTg1NTA5Il0sInhtc190Y2R0IjoxNDQ0ODQ1NTQ0fQ.A1Y7A4hAr219H1d2lAGrJWIrI7DP-hvOBceaD0OQY9K23dn-bHw5ReiEp0PMqUzOB3acTRHaWRKsRjLfO11tpDrbapVsMhL0MMo49Fdvdeg410P_jYfwGU6B28D12qNsTaXgez3fNCqc3GJsC-ghjXkE-PiC1fccRCmOYTbCigncFTE139bXIzDbtiUwTFeTh-Hh3NUb8Vq31lVhaxHT11Pf8vqx84UwG70lX_FSHwGuY35GdNtbChji-R_O7nnO_LcHQo77sMUYR15NNoRAiw-kFjoWUmsaBLVVO0fivorP_84bvsPKDtt_VCvEsyVPpZU6tg6v3zOibU47qOvgSQ"
    "x-ms-effective-locale"  = "en.en-us"
    "Accept"                 = "*/*"
    "x-ms-client-request-id" = "bb07f179-58cc-4644-bcad-809613390007"
} `
    -ContentType "application/json"

    #>
<#
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36 Edg/93.0.961.38"
(Invoke-WebRequest -UseBasicParsing -Uri "https://graph.microsoft.com/beta/settings" `
    -WebSession $session `
    -Headers @{
    "x-ms-client-session-id" = "820dcf17f6cd473d84759b81f8374113"
    "Accept-Language"        = "en"
    "Authorization"          = "Bearer eyJ0eXAiOiJKV1QiLCJub25jZSI6Ii1halNWVm5HNFphaVVMeHotbXFzckpHN2prbDJIQTlMdGFSZW45MTBRcW8iLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20vIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvY2ViMzcxZjYtODc0NS00ODc2LWEwNDAtNjlmMmQxMGE5ZDFhLyIsImlhdCI6MTYzMDg0MzQxNiwibmJmIjoxNjMwODQzNDE2LCJleHAiOjE2MzA4NDczMTUsImFjY3QiOjAsImFjciI6IjEiLCJhaW8iOiJBVVFBdS84VEFBQUFnMlk4VlNqbjR5Q1E0V1E2SC9aZ0QvZWN6RjFWRytJbUo2b0VKNEhrVnlkNUJxV2tjZUhvY2pmbTZMU002WTF0aXVMQXRnb1VabUF5cXJ1YWlTUFhjQT09IiwiYW1yIjpbInJzYSIsIm1mYSJdLCJhcHBfZGlzcGxheW5hbWUiOiJBREliaXphVVgiLCJhcHBpZCI6Ijc0NjU4MTM2LTE0ZWMtNDYzMC1hZDliLTI2ZTE2MGZmMGZjNiIsImFwcGlkYWNyIjoiMiIsImNvbnRyb2xzIjpbImNhX2VuZiJdLCJkZXZpY2VpZCI6IjNhZTIyNzI2LWRmZDktNGFkNy1hODY1LWFhMmI1MWM2ZTBmZiIsImZhbWlseV9uYW1lIjoiS8WCeXMiLCJnaXZlbl9uYW1lIjoiUHJ6ZW15c8WCYXciLCJpZHR5cCI6InVzZXIiLCJpcGFkZHIiOiI4OS43Ny4xMDIuMTciLCJuYW1lIjoiUHJ6ZW15c8WCYXcgS8WCeXMiLCJvaWQiOiJlNmE4ZjFjZi0wODc0LTQzMjMtYTEyZi0yYmY1MWJiNmRmZGQiLCJvbnByZW1fc2lkIjoiUy0xLTUtMjEtODUzNjE1OTg1LTI4NzA0NDUzMzktMzE2MzU5ODY1OS0xMTA1IiwicGxhdGYiOiIzIiwicHVpZCI6IjEwMDMwMDAwOTQ0REI4NEQiLCJyaCI6IjAuQVM4QTluR3p6a1dIZGtpZ1FHbnkwUXFkR2phQlpYVHNGREJHclpzbTRXRF9EOFl2QUM4LiIsInNjcCI6IkFjY2Vzc1Jldmlldy5SZWFkV3JpdGUuQWxsIEF1ZGl0TG9nLlJlYWQuQWxsIERpcmVjdG9yeS5BY2Nlc3NBc1VzZXIuQWxsIERpcmVjdG9yeS5SZWFkLkFsbCBEaXJlY3RvcnkuUmVhZFdyaXRlLkFsbCBlbWFpbCBFbnRpdGxlbWVudE1hbmFnZW1lbnQuUmVhZC5BbGwgR3JvdXAuUmVhZFdyaXRlLkFsbCBJZGVudGl0eVByb3ZpZGVyLlJlYWRXcml0ZS5BbGwgSWRlbnRpdHlSaXNrRXZlbnQuUmVhZFdyaXRlLkFsbCBJZGVudGl0eVVzZXJGbG93LlJlYWQuQWxsIG9wZW5pZCBQb2xpY3kuUmVhZC5BbGwgUG9saWN5LlJlYWRXcml0ZS5BdXRoZW50aWNhdGlvbkZsb3dzIFBvbGljeS5SZWFkV3JpdGUuQXV0aGVudGljYXRpb25NZXRob2QgUG9saWN5LlJlYWRXcml0ZS5Db25kaXRpb25hbEFjY2VzcyBwcm9maWxlIFJlcG9ydHMuUmVhZC5BbGwgUm9sZU1hbmFnZW1lbnQuUmVhZFdyaXRlLkRpcmVjdG9yeSBTZWN1cml0eUV2ZW50cy5SZWFkV3JpdGUuQWxsIFRydXN0RnJhbWV3b3JrS2V5U2V0LlJlYWQuQWxsIFVzZXIuRXhwb3J0LkFsbCBVc2VyLlJlYWRXcml0ZS5BbGwgVXNlckF1dGhlbnRpY2F0aW9uTWV0aG9kLlJlYWRXcml0ZS5BbGwiLCJzaWduaW5fc3RhdGUiOlsiZHZjX21uZ2QiLCJkdmNfY21wIiwiZHZjX2RtamQiXSwic3ViIjoiQ0VzQmE1TXJwYnM0bUU1UEx0RmxWaE03TjlndmVMZjNVbEp1OWl5NWZrOCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJFVSIsInRpZCI6ImNlYjM3MWY2LTg3NDUtNDg3Ni1hMDQwLTY5ZjJkMTBhOWQxYSIsInVuaXF1ZV9uYW1lIjoicHJ6ZW15c2xhdy5rbHlzQGV2b3RlYy5wbCIsInVwbiI6InByemVteXNsYXcua2x5c0Bldm90ZWMucGwiLCJ1dGkiOiJfRW1NdERwYktVT083SmRkelF4N0FBIiwidmVyIjoiMS4wIiwid2lkcyI6WyI2MmU5MDM5NC02OWY1LTQyMzctOTE5MC0wMTIxNzcxNDVlMTAiLCJiNzlmYmY0ZC0zZWY5LTQ2ODktODE0My03NmIxOTRlODU1MDkiXSwieG1zX3N0Ijp7InN1YiI6ImVvU3lzNXlDNmJvWmQ5a21YRXVNSWl5YUxhX1g1VTdmSWZJck1DV0hORjQifSwieG1zX3RjZHQiOjE0NDQ4NDU1NDR9.RNtShDZhTXTmvaRb4J9O3S6lDxTC-jwFIvc-7x1msXo0tyNQgtgN23Gwvy4YnN1WRn99PxUQIBEkq5xCbW6BzXjst4uz8NjaIu3x8ilzYzEXHthRC2gjRZ25h7OnU5EpbxQanxYze8ESOtXRvmAtRFwEh8CrijJOz5NttiH_ctbkVOPnSsTyUBXp2r74ulxL8GWcSMawSLLtAsjEOX4jtn-8-xp6KEe5UV0KJvqRGTBf2fDvbdYZJUuaG8uBDymUeFx2pMgD1zTGv7_8kmiV5IhDFakYxaDPMYp5kc6kIaUbMwmEn5tbJrDdVcJ4j5cvSGm7DxRjB45DiwcFaM9Hpw"
    "x-ms-effective-locale"  = "en.en-us"
    "Accept"                 = "*/*"
    "x-ms-client-request-id" = "bb07f179-58cc-4644-bcad-809613390009"
}).Content | ConvertFrom-Json | Select-Object -ExpandProperty value


$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36 Edg/93.0.961.38"
(Invoke-WebRequest -UseBasicParsing -Uri "https://main.iam.ad.ext.azure.com/api/RequestApprovals/V2/PolicyTemplates?type=AdminConsentFlow" `
    -WebSession $session `
    -Headers @{
    "x-ms-client-session-id" = "820dcf17f6cd473d84759b81f8374113"
    "Accept-Language"        = "en"
    "Authorization"          = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiI3NDY1ODEzNi0xNGVjLTQ2MzAtYWQ5Yi0yNmUxNjBmZjBmYzYiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9jZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEvIiwiaWF0IjoxNjMwODQzNDE2LCJuYmYiOjE2MzA4NDM0MTYsImV4cCI6MTYzMDg0NzMxNiwiYWNyIjoiMSIsImFpbyI6IkFWUUFxLzhUQUFBQUhnV05Sa0IrbTY3VVRwQWpnSjlVcFpUdFl5QmpWNDR2RDhiMjlsK0h3akdxM0pYK0NGdi84Ynh3ZGl0ZnZ1a2JreVJiaS9IMkdGNVJNZTAveXJ4VlpEYjBvQ1ZDL2thTU5TT2lRQVJYTU04PSIsImFtciI6WyJyc2EiLCJtZmEiXSwiYXBwaWQiOiJjNDRiNDA4My0zYmIwLTQ5YzEtYjQ3ZC05NzRlNTNjYmRmM2MiLCJhcHBpZGFjciI6IjIiLCJkZXZpY2VpZCI6IjNhZTIyNzI2LWRmZDktNGFkNy1hODY1LWFhMmI1MWM2ZTBmZiIsImZhbWlseV9uYW1lIjoiS8WCeXMiLCJnaXZlbl9uYW1lIjoiUHJ6ZW15c8WCYXciLCJpcGFkZHIiOiI4OS43Ny4xMDIuMTciLCJuYW1lIjoiUHJ6ZW15c8WCYXcgS8WCeXMiLCJvaWQiOiJlNmE4ZjFjZi0wODc0LTQzMjMtYTEyZi0yYmY1MWJiNmRmZGQiLCJvbnByZW1fc2lkIjoiUy0xLTUtMjEtODUzNjE1OTg1LTI4NzA0NDUzMzktMzE2MzU5ODY1OS0xMTA1IiwicHVpZCI6IjEwMDMwMDAwOTQ0REI4NEQiLCJyaCI6IjAuQVM4QTluR3p6a1dIZGtpZ1FHbnkwUXFkR29OQVM4U3dPOEZKdEgyWFRsUEwzend2QUM4LiIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInN1YiI6ImVvU3lzNXlDNmJvWmQ5a21YRXVNSWl5YUxhX1g1VTdmSWZJck1DV0hORjQiLCJ0ZW5hbnRfcmVnaW9uX3Njb3BlIjoiRVUiLCJ0aWQiOiJjZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEiLCJ1bmlxdWVfbmFtZSI6InByemVteXNsYXcua2x5c0Bldm90ZWMucGwiLCJ1cG4iOiJwcnplbXlzbGF3LmtseXNAZXZvdGVjLnBsIiwidXRpIjoiSGJid2laanlMVS13TWVJOHRrTm9BQSIsInZlciI6IjEuMCIsIndpZHMiOlsiNjJlOTAzOTQtNjlmNS00MjM3LTkxOTAtMDEyMTc3MTQ1ZTEwIiwiYjc5ZmJmNGQtM2VmOS00Njg5LTgxNDMtNzZiMTk0ZTg1NTA5Il0sInhtc190Y2R0IjoxNDQ0ODQ1NTQ0fQ.A1Y7A4hAr219H1d2lAGrJWIrI7DP-hvOBceaD0OQY9K23dn-bHw5ReiEp0PMqUzOB3acTRHaWRKsRjLfO11tpDrbapVsMhL0MMo49Fdvdeg410P_jYfwGU6B28D12qNsTaXgez3fNCqc3GJsC-ghjXkE-PiC1fccRCmOYTbCigncFTE139bXIzDbtiUwTFeTh-Hh3NUb8Vq31lVhaxHT11Pf8vqx84UwG70lX_FSHwGuY35GdNtbChji-R_O7nnO_LcHQo77sMUYR15NNoRAiw-kFjoWUmsaBLVVO0fivorP_84bvsPKDtt_VCvEsyVPpZU6tg6v3zOibU47qOvgSQ"
    "x-ms-effective-locale"  = "en.en-us"
    "Accept"                 = "*/*"
    "x-ms-client-request-id" = "bb07f179-58cc-4644-bcad-80961339003d"
} `
    -ContentType "application/json").content | ConvertFrom-Json


$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36 Edg/93.0.961.38"
(Invoke-WebRequest -UseBasicParsing -Uri "https://main.iam.ad.ext.azure.com/api/workspaces/promotedapps" `
    -WebSession $session `
    -Headers @{
    "x-ms-client-session-id" = "820dcf17f6cd473d84759b81f8374113"
    "Accept-Language"        = "en"
    "Authorization"          = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiI3NDY1ODEzNi0xNGVjLTQ2MzAtYWQ5Yi0yNmUxNjBmZjBmYzYiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9jZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEvIiwiaWF0IjoxNjMwODQzNDE2LCJuYmYiOjE2MzA4NDM0MTYsImV4cCI6MTYzMDg0NzMxNiwiYWNyIjoiMSIsImFpbyI6IkFWUUFxLzhUQUFBQUhnV05Sa0IrbTY3VVRwQWpnSjlVcFpUdFl5QmpWNDR2RDhiMjlsK0h3akdxM0pYK0NGdi84Ynh3ZGl0ZnZ1a2JreVJiaS9IMkdGNVJNZTAveXJ4VlpEYjBvQ1ZDL2thTU5TT2lRQVJYTU04PSIsImFtciI6WyJyc2EiLCJtZmEiXSwiYXBwaWQiOiJjNDRiNDA4My0zYmIwLTQ5YzEtYjQ3ZC05NzRlNTNjYmRmM2MiLCJhcHBpZGFjciI6IjIiLCJkZXZpY2VpZCI6IjNhZTIyNzI2LWRmZDktNGFkNy1hODY1LWFhMmI1MWM2ZTBmZiIsImZhbWlseV9uYW1lIjoiS8WCeXMiLCJnaXZlbl9uYW1lIjoiUHJ6ZW15c8WCYXciLCJpcGFkZHIiOiI4OS43Ny4xMDIuMTciLCJuYW1lIjoiUHJ6ZW15c8WCYXcgS8WCeXMiLCJvaWQiOiJlNmE4ZjFjZi0wODc0LTQzMjMtYTEyZi0yYmY1MWJiNmRmZGQiLCJvbnByZW1fc2lkIjoiUy0xLTUtMjEtODUzNjE1OTg1LTI4NzA0NDUzMzktMzE2MzU5ODY1OS0xMTA1IiwicHVpZCI6IjEwMDMwMDAwOTQ0REI4NEQiLCJyaCI6IjAuQVM4QTluR3p6a1dIZGtpZ1FHbnkwUXFkR29OQVM4U3dPOEZKdEgyWFRsUEwzend2QUM4LiIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInN1YiI6ImVvU3lzNXlDNmJvWmQ5a21YRXVNSWl5YUxhX1g1VTdmSWZJck1DV0hORjQiLCJ0ZW5hbnRfcmVnaW9uX3Njb3BlIjoiRVUiLCJ0aWQiOiJjZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEiLCJ1bmlxdWVfbmFtZSI6InByemVteXNsYXcua2x5c0Bldm90ZWMucGwiLCJ1cG4iOiJwcnplbXlzbGF3LmtseXNAZXZvdGVjLnBsIiwidXRpIjoiSGJid2laanlMVS13TWVJOHRrTm9BQSIsInZlciI6IjEuMCIsIndpZHMiOlsiNjJlOTAzOTQtNjlmNS00MjM3LTkxOTAtMDEyMTc3MTQ1ZTEwIiwiYjc5ZmJmNGQtM2VmOS00Njg5LTgxNDMtNzZiMTk0ZTg1NTA5Il0sInhtc190Y2R0IjoxNDQ0ODQ1NTQ0fQ.A1Y7A4hAr219H1d2lAGrJWIrI7DP-hvOBceaD0OQY9K23dn-bHw5ReiEp0PMqUzOB3acTRHaWRKsRjLfO11tpDrbapVsMhL0MMo49Fdvdeg410P_jYfwGU6B28D12qNsTaXgez3fNCqc3GJsC-ghjXkE-PiC1fccRCmOYTbCigncFTE139bXIzDbtiUwTFeTh-Hh3NUb8Vq31lVhaxHT11Pf8vqx84UwG70lX_FSHwGuY35GdNtbChji-R_O7nnO_LcHQo77sMUYR15NNoRAiw-kFjoWUmsaBLVVO0fivorP_84bvsPKDtt_VCvEsyVPpZU6tg6v3zOibU47qOvgSQ"
    "x-ms-effective-locale"  = "en.en-us"
    "Accept"                 = "*/*"
    "x-ms-client-request-id" = "bb07f179-58cc-4644-bcad-809613390038"
}).content | ConvertFrom-Json

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36 Edg/93.0.961.38"
(Invoke-WebRequest -UseBasicParsing -Uri "https://main.iam.ad.ext.azure.com/api/EnterpriseApplications/UserSettings" `
    -WebSession $session `
    -Headers @{
    "x-ms-client-session-id" = "820dcf17f6cd473d84759b81f8374113"
    "Accept-Language"        = "en"
    "Authorization"          = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiI3NDY1ODEzNi0xNGVjLTQ2MzAtYWQ5Yi0yNmUxNjBmZjBmYzYiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9jZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEvIiwiaWF0IjoxNjMwODQzNDE2LCJuYmYiOjE2MzA4NDM0MTYsImV4cCI6MTYzMDg0NzMxNiwiYWNyIjoiMSIsImFpbyI6IkFWUUFxLzhUQUFBQUhnV05Sa0IrbTY3VVRwQWpnSjlVcFpUdFl5QmpWNDR2RDhiMjlsK0h3akdxM0pYK0NGdi84Ynh3ZGl0ZnZ1a2JreVJiaS9IMkdGNVJNZTAveXJ4VlpEYjBvQ1ZDL2thTU5TT2lRQVJYTU04PSIsImFtciI6WyJyc2EiLCJtZmEiXSwiYXBwaWQiOiJjNDRiNDA4My0zYmIwLTQ5YzEtYjQ3ZC05NzRlNTNjYmRmM2MiLCJhcHBpZGFjciI6IjIiLCJkZXZpY2VpZCI6IjNhZTIyNzI2LWRmZDktNGFkNy1hODY1LWFhMmI1MWM2ZTBmZiIsImZhbWlseV9uYW1lIjoiS8WCeXMiLCJnaXZlbl9uYW1lIjoiUHJ6ZW15c8WCYXciLCJpcGFkZHIiOiI4OS43Ny4xMDIuMTciLCJuYW1lIjoiUHJ6ZW15c8WCYXcgS8WCeXMiLCJvaWQiOiJlNmE4ZjFjZi0wODc0LTQzMjMtYTEyZi0yYmY1MWJiNmRmZGQiLCJvbnByZW1fc2lkIjoiUy0xLTUtMjEtODUzNjE1OTg1LTI4NzA0NDUzMzktMzE2MzU5ODY1OS0xMTA1IiwicHVpZCI6IjEwMDMwMDAwOTQ0REI4NEQiLCJyaCI6IjAuQVM4QTluR3p6a1dIZGtpZ1FHbnkwUXFkR29OQVM4U3dPOEZKdEgyWFRsUEwzend2QUM4LiIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInN1YiI6ImVvU3lzNXlDNmJvWmQ5a21YRXVNSWl5YUxhX1g1VTdmSWZJck1DV0hORjQiLCJ0ZW5hbnRfcmVnaW9uX3Njb3BlIjoiRVUiLCJ0aWQiOiJjZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEiLCJ1bmlxdWVfbmFtZSI6InByemVteXNsYXcua2x5c0Bldm90ZWMucGwiLCJ1cG4iOiJwcnplbXlzbGF3LmtseXNAZXZvdGVjLnBsIiwidXRpIjoiSGJid2laanlMVS13TWVJOHRrTm9BQSIsInZlciI6IjEuMCIsIndpZHMiOlsiNjJlOTAzOTQtNjlmNS00MjM3LTkxOTAtMDEyMTc3MTQ1ZTEwIiwiYjc5ZmJmNGQtM2VmOS00Njg5LTgxNDMtNzZiMTk0ZTg1NTA5Il0sInhtc190Y2R0IjoxNDQ0ODQ1NTQ0fQ.A1Y7A4hAr219H1d2lAGrJWIrI7DP-hvOBceaD0OQY9K23dn-bHw5ReiEp0PMqUzOB3acTRHaWRKsRjLfO11tpDrbapVsMhL0MMo49Fdvdeg410P_jYfwGU6B28D12qNsTaXgez3fNCqc3GJsC-ghjXkE-PiC1fccRCmOYTbCigncFTE139bXIzDbtiUwTFeTh-Hh3NUb8Vq31lVhaxHT11Pf8vqx84UwG70lX_FSHwGuY35GdNtbChji-R_O7nnO_LcHQo77sMUYR15NNoRAiw-kFjoWUmsaBLVVO0fivorP_84bvsPKDtt_VCvEsyVPpZU6tg6v3zOibU47qOvgSQ"
    "x-ms-effective-locale"  = "en.en-us"
    "Accept"                 = "*/*"
    "x-ms-client-request-id" = "bb07f179-58cc-4644-bcad-80961339003b"
} `
    -ContentType "application/json").Content | ConvertFrom-Json
    #>