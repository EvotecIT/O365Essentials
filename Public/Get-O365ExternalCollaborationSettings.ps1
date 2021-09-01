function Get-O365ExternalCollaborationSettings {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $ReverseGuestRole = @{
        'a0b1b346-4d3e-4e8b-98f8-753987be4970' = 'User'
        '10dae51f-b6af-4016-8d66-8c2a99b929b3' = 'GuestUser'
        '2af84b1e-32c8-42b7-82bc-daa82404023b' = 'RestrictedUser'
    }

    $Uri = 'https://graph.microsoft.com/v1.0/policies/authorizationPolicy'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        [PSCustomObject] @{
            #id                                        = $Output.id                                        # : authorizationPolicy
            allowInvitesFrom                          = $Output.allowInvitesFrom                          # : adminsAndGuestInviters
            allowedToSignUpEmailBasedSubscriptions    = $Output.allowedToSignUpEmailBasedSubscriptions    # : True
            allowedToUseSSPR                          = $Output.allowedToUseSSPR                          # : True
            allowEmailVerifiedUsersToJoinOrganization = $Output.allowEmailVerifiedUsersToJoinOrganization # : False
            blockMsolPowerShell                       = $Output.blockMsolPowerShell                       # : False
            displayName                               = $Output.displayName                               # : Authorization Policy
            description                               = $Output.description                               # : Used to manage authorization related settings across the company.
            guestUserRoleId                           = $ReverseGuestRole[$Output.guestUserRoleId]                           # : a0b1b346-4d3e-4e8b-98f8-753987be4970
            defaultUserRolePermissions                = $Output.defaultUserRolePermissions                # :
        }
    }
}

<#
$o = Invoke-WebRequest -Uri "https://graph.microsoft.com/beta/policies/authenticationFlowsPolicy" -Headers @{
    "x-ms-client-session-id" = "a2f6c5f9b1b8450dbb0116f95ffbe9b2"
    "Accept-Language"        = "en"
    "Authorization"          = "Bearer .KbPkFbOvi76GsB-ir_fvW9EvLaotYG2DOrdBBrunyPESmmPrB8Om05KWmphQhaIwGkz2MLTrP8dle75xJgLbq6MB6IpNiQcIWfoiblOmuM3MM37TpZqGNJyM4GV3IQ06zPXmnAVYt1C4q6Hh4yjRznTFxmWiS7jN8al5KwyKSBLjd2NtFxQr6ADeV0isDhsTPiFmIHG7DfN9atQmiPSxZkHsvw6bXygwiBGShra0tjT3mLx5bJK3MDcbw8sSGT6eRKwuTYbGbcYsYK-JYMHjIIq1llszFdv_K8CsW1slk1ZfOahm_ebFCsuRytjwdtqe7d8Zh1yWCeVo5h6JzR_aw"
    "x-ms-effective-locale"  = "en.en-us"
    "Accept"                 = "*/*"
    #"Referer"=""
    "x-ms-client-request-id" = "d4bc027d-339c-46c2-ba96-c07f53fc5002"
    "User-Agent"             = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84"
}
$o.content

$p = Invoke-WebRequest -Uri "https://graph.microsoft.com/beta/policies/authorizationPolicy" -Headers @{
    "x-ms-client-session-id" = "a2f6c5f9b1b8450dbb0116f95ffbe9b2"
    "Accept-Language"        = "en"
    "Authorization"          = "Bearer ..oKbPkFbOvi76GsB-ir_fvW9EvLaotYG2DOrdBBrunyPESmmPrB8Om05KWmphQhaIwGkz2MLTrP8dle75xJgLbq6MB6IpNiQcIWfoiblOmuM3MM37TpZqGNJyM4GV3IQ06zPXmnAVYt1C4q6Hh4yjRznTFxmWiS7jN8al5KwyKSBLjd2NtFxQr6ADeV0isDhsTPiFmIHG7DfN9atQmiPSxZkHsvw6bXygwiBGShra0tjT3mLx5bJK3MDcbw8sSGT6eRKwuTYbGbcYsYK-JYMHjIIq1llszFdv_K8CsW1slk1ZfOahm_ebFCsuRytjwdtqe7d8Zh1yWCeVo5h6JzR_aw"
    "x-ms-effective-locale"  = "en.en-us"
    "Accept"                 = "*/*"
    #"Referer"                = ""
    "x-ms-client-request-id" = "d4bc027d-339c-46c2-ba96-c07f53fc5001"
    "User-Agent"             = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84"
}
$p.COntent

$g = Invoke-WebRequest -Uri "https://main.iam.ad.ext.azure.com/api/B2B/b2bPolicy" `
    -Headers @{
    "x-ms-client-session-id" = "02ca6867073543de9a89b767ad581135"
    "Accept-Language"        = "en"
    "Authorization"          = "Bearer hdWQiOiI3NDY1ODEzNi0xNGVjLTQ2MzAtYWQ5Yi0yNmUxNjBmZjBmYzYiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9jZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEvIiwiaWF0IjoxNjMwNDkxNzAyLCJuYmYiOjE2MzA0OTE3MDIsImV4cCI6MTYzMDQ5NTYwMiwiYWNyIjoiMSIsImFpbyI6IkFWUUFxLzhUQUFBQU9ENWlhYUlWTmVEdG5JZnFkcGhMMGJhdm13VHlOMUtnV3lOa3RsWkx2WUhDK2RYdkhzOW04TlBYd0NDRXkyaCs0UjRoR1lKRDdWOGNGWjQvbkJkNk00L1gyS3NWQ0YrdGFkejQrNXFseEpvPSIsImFtciI6WyJyc2EiLCJtZmEiXSwiYXBwaWQiOiJjNDRiNDA4My0zYmIwLTQ5YzEtYjQ3ZC05NzRlNTNjYmRmM2MiLCJhcHBpZGFjciI6IjIiLCJkZXZpY2VpZCI6IjNhZTIyNzI2LWRmZDktNGFkNy1hODY1LWFhMmI1MWM2ZTBmZiIsImZhbWlseV9uYW1lIjoiS8WCeXMiLCJnaXZlbl9uYW1lIjoiUHJ6ZW15c8WCYXciLCJpcGFkZHIiOiI4OS43Ny4xMDIuMTciLCJuYW1lIjoiUHJ6ZW15c8WCYXcgS8WCeXMiLCJvaWQiOiJlNmE4ZjFjZi0wODc0LTQzMjMtYTEyZi0yYmY1MWJiNmRmZGQiLCJvbnByZW1fc2lkIjoiUy0xLTUtMjEtODUzNjE1OTg1LTI4NzA0NDUzMzktMzE2MzU5ODY1OS0xMTA1IiwicHVpZCI6IjEwMDMwMDAwOTQ0REI4NEQiLCJyaCI6IjAuQVM4QTluR3p6a1dIZGtpZ1FHbnkwUXFkR29OQVM4U3dPOEZKdEgyWFRsUEwzend2QUM4LiIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInN1YiI6ImVvU3lzNXlDNmJvWmQ5a21YRXVNSWl5YUxhX1g1VTdmSWZJck1DV0hORjQiLCJ0ZW5hbnRfcmVnaW9uX3Njb3BlIjoiRVUiLCJ0aWQiOiJjZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEiLCJ1bmlxdWVfbmFtZSI6InByemVteXNsYXcua2x5c0Bldm90ZWMucGwiLCJ1cG4iOiJwcnplbXlzbGF3LmtseXNAZXZvdGVjLnBsIiwidXRpIjoicUZHYnNtdXlxVWlQa2N1ckJ2S0ZBQSIsInZlciI6IjEuMCIsIndpZHMiOlsiNjJlOTAzOTQtNjlmNS00MjM3LTkxOTAtMDEyMTc3MTQ1ZTEwIiwiYjc5ZmJmNGQtM2VmOS00Njg5LTgxNDMtNzZiMTk0ZTg1NTA5Il0sInhtc190Y2R0IjoxNDQ0ODQ1NTQ0fQ.AjE1BT09g0XFj5PwNq5LyqMrDwonge69AN9HPjMx2G5yyNryeyCLg8j30GHYr9UtrFT8pbyRpN5RGrKEeSh5jYrezR1UdIBn8wPV2CNgSQla9logWiMihjZMBNrf5ZMNak5L9T78vHM5nD0i5GSvNGhbcfWPTxWBVgbnn206VufjMhAcXyM92nXpiH9i_Ho9OJtZsDP_sM24fJWkyIuaSelnYU5_ipBVIZ4YiTjcIKJv2hed-Rss_d9rPcC4uloL3KFpFh0kdxVFBvcxot11z2_P19H9cGvnGJjgq5v9oxOjo2iUUJsBxa4SxchTuMU2NdeQpB7PfbEyV7vcC8AuNA"
    "x-ms-effective-locale"  = "en.en-us"
    "Accept"                 = "*/*"
    #"Referer"                = ""
    "User-Agent"             = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84"
    "x-ms-client-request-id" = "cf957d13-fc12-415d-a86a-1d74507d9003"
} `
    -ContentType "application/json"
$g.content
#>