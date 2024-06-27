function Get-O365AzureADRoles {
    <#
    .SYNOPSIS
    Retrieves Azure AD roles from Microsoft Graph API.

    .DESCRIPTION
    This function retrieves Azure AD roles from the Microsoft Graph API based on the provided URI.
    It returns a list of Azure AD roles.
    #>
    [cmdletBinding()]
    param(

    )

    #https://graph.microsoft.com/beta/roleManagement/directory/roleAssignments&$filter=roleDefinitionId eq ‘<object-id-or-template-id-of-role-definition>’


    #$Uri = 'https://main.iam.ad.ext.azure.com/api/Roles/User/e6a8f1cf-0874-4323-a12f-2bf51bb6dfdd/RoleAssignments?scope=undefined'
    $Uri = 'https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions'
    <#
    $QueryParameter = @{
        '$Select'  = $Property -join ','
        '$filter'  = $Filter
        '$orderby' = $OrderBy
    }
    #>
    <#
    GET https://graph.microsoft.com/beta/roleManagement/directory/roleDefinitions?$filter=DisplayName eq 'Conditional Access Administrator'&$select=rolePermissions
    #>
    Write-Verbose -Message "Get-O365AzureADRoles - Getting all Azure AD Roles"
    $Script:AzureADRolesList = [ordered] @{}
    $Script:AzureADRolesListReverse = [ordered] @{}
    $RolesList = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter -Method GET
    $Script:AzureADRoles = $RolesList
    foreach ($Role in $RolesList) {
        $Script:AzureADRolesList[$Role.id] = $Role
        $Script:AzureADRolesListReverse[$Role.displayName] = $Role
    }

    $RolesList
}

<#
Invoke-WebRequest -Uri "https://main.iam.ad.ext.azure.com/api/Roles/User/e6a8f1cf-0874-4323-a12f-2bf51bb6dfdd/RoleAssignments?scope=undefined" `
-Method "OPTIONS" `
-Headers @{
"Accept"="*/*"
  "Access-Control-Request-Method"="GET"
  "Access-Control-Request-Headers"="authorization,content-type,x-ms-client-request-id,x-ms-client-session-id,x-ms-effective-locale"
  "Origin"="https://portal.azure.com"
  "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84"
  "Sec-Fetch-Mode"="cors"
  "Sec-Fetch-Site"="same-site"
  "Sec-Fetch-Dest"="empty"
  "Accept-Encoding"="gzip, deflate, br"
  "Accept-Language"="en-US,en;q=0.9,pl;q=0.8"
}
#>


<#

GET https://admin.exchange.microsoft.com/beta/RoleGroup? HTTP/1.1
Host: admin.exchange.microsoft.com
Connection: keep-alive
sec-ch-ua: "Chromium";v="92", " Not A;Brand";v="99", "Microsoft Edge";v="92"
x-ms-mac-hostingapp: M365AdminPortal
AjaxSessionKey: x5eAwqzbVehBOP7QHfrjpwr9eYtLiHJt7TZFj0uhUMUPQ2T7yNdA7rEgOulejHDHYM1ZyCT0pgXo96EwrfVpMA==
x-adminapp-request: /rbac/exchange
sec-ch-ua-mobile: ?0
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiI0OTdlZmZlOS1kZjcxLTQwNDMtYThiYi0xNGNmNzhjNGI2M2IiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9jZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEvIiwiaWF0IjoxNjMwMjYwMjMxLCJuYmYiOjE2MzAyNjAyMzEsImV4cCI6MTYzMDI2NDEzMSwiYWNyIjoiMSIsImFpbyI6IkFWUUFxLzhUQUFBQXBtQ1F1b2lIR3lpYTd0dFB0czFZOEpIWUpleTB1Zndzb2oycUFvSEJKWjhQclowWlJONmhQSW5BblZHRld2cXp1R0xtbXNyS1Vaak12ZVBwNDJsQXhHY0d1bk5ZNTNNMmdWbE9uSXRhcHBrPSIsImFtciI6WyJyc2EiLCJtZmEiXSwiYXBwaWQiOiIwMDAwMDAwNi0wMDAwLTBmZjEtY2UwMC0wMDAwMDAwMDAwMDAiLCJhcHBpZGFjciI6IjIiLCJkZXZpY2VpZCI6IjNhZTIyNzI2LWRmZDktNGFkNy1hODY1LWFhMmI1MWM2ZTBmZiIsImZhbWlseV9uYW1lIjoiS8WCeXMiLCJnaXZlbl9uYW1lIjoiUHJ6ZW15c8WCYXciLCJpcGFkZHIiOiI4OS43Ny4xMDIuMTciLCJuYW1lIjoiUHJ6ZW15c8WCYXcgS8WCeXMiLCJvaWQiOiJlNmE4ZjFjZi0wODc0LTQzMjMtYTEyZi0yYmY1MWJiNmRmZGQiLCJvbnByZW1fc2lkIjoiUy0xLTUtMjEtODUzNjE1OTg1LTI4NzA0NDUzMzktMzE2MzU5ODY1OS0xMTA1IiwicHVpZCI6IjEwMDMwMDAwOTQ0REI4NEQiLCJyaCI6IjAuQVM4QTluR3p6a1dIZGtpZ1FHbnkwUXFkR2dZQUFBQUFBUEVQemdBQUFBQUFBQUF2QUM4LiIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInNpZCI6ImJkYjU3MmNiLTNkMzgtNGZlZi1iNjg2LTlmODhjNWRkNWQyNSIsInN1YiI6ImRranZjSlpIWjdjWkZPbnlSZkxZaDVLeHBUalVWdEVBLTVNSl81aF9GLWMiLCJ0aWQiOiJjZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEiLCJ1bmlxdWVfbmFtZSI6InByemVteXNsYXcua2x5c0Bldm90ZWMucGwiLCJ1cG4iOiJwcnplbXlzbGF3LmtseXNAZXZvdGVjLnBsIiwidXRpIjoiekxXUTdvUmc4ay0yVmlJV1dQNG1BQSIsInZlciI6IjEuMCIsIndpZHMiOlsiNjJlOTAzOTQtNjlmNS00MjM3LTkxOTAtMDEyMTc3MTQ1ZTEwIiwiYjc5ZmJmNGQtM2VmOS00Njg5LTgxNDMtNzZiMTk0ZTg1NTA5Il19.nzALEBEAAQBJddeeyt7Gn5sgy7y1Z1z_jfpLdjsPjgNSEOlHLPHqeyOx9QuHaEywK6es2pobYfhFtUvx1d09nz0qBI0b1wIRMX2W2-XaQOmg0FRTDQvTcC9d4Kum_hXmpTt8WgIpjKLKE0wmW8ZtsHbmh-JH3m9Y8j-9zktiRFtNbEyEa1uCTD7Wph9Ow_PAc6M9mWrERCb_XzaYDuwZWbfA_Ls2Bv8MGQsfkQh9RBsa-TgeuU1hhhGgcSaHPFAytJVQBq6QuMdqnO1pCevECf_OI2K54CcpISAUAPXW_gZXcj1waXzRRQfm85vCCh14oXvEj-Q94RsSq_5c_8cEFA
client-request-id: 64d0ca10-08f4-11ec-ad6e-f9fb25a685f4
Accept: application/json, text/plain, */*
x-ms-mac-version: host-mac_2021.8.19.4
x-portal-routekey: weu
x-ms-mac-appid: 86d5ab1a-7f52-418c-b62d-a33841f2c949
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84
x-ms-mac-target-app: EAC
Origin: https://admin.microsoft.com
Sec-Fetch-Site: same-site
Sec-Fetch-Mode: cors
Sec-Fetch-Dest: empty
Referer: https://admin.microsoft.com/
Accept-Encoding: gzip, deflate, br
Accept-Language: en-US,en;q=0.9,pl;q=0.8



GET https://admin.microsoft.com/admin/api/rbac/deviceManagement/roles HTTP/1.1
Host: admin.microsoft.com
Connection: keep-alive
sec-ch-ua: "Chromium";v="92", " Not A;Brand";v="99", "Microsoft Edge";v="92"
x-ms-mac-hostingapp: M365AdminPortal
AjaxSessionKey: x5eAwqzbVehBOP7QHfrjpwr9eYtLiHJt7TZFj0uhUMUPQ2T7yNdA7rEgOulejHDHYM1ZyCT0pgXo96EwrfVpMA==
x-adminapp-request: /rbac/deviceManagement
sec-ch-ua-mobile: ?0
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.84
Accept: application/json, text/plain, */*
x-ms-mac-version: host-mac_2021.8.19.4
x-portal-routekey: weu
x-ms-mac-appid: 86d5ab1a-7f52-418c-b62d-a33841f2c949
x-ms-mac-target-app: MAC
Sec-Fetch-Site: same-origin
Sec-Fetch-Mode: cors
Sec-Fetch-Dest: empty
Referer: https://admin.microsoft.com/
Accept-Encoding: gzip, deflate, br
Accept-Language: en-US,en;q=0.9,pl;q=0.8
Cookie: MC1=GUID=480c128a5ba04faea7df151a53bdfa9a&HASH=480c&LV=202107&V=4&LU=1627670649689; x-portal-routekey=weu; p.BDId=00ab552e-0bd2-44f6-afb9-cbec94cb4051; s.AjaxSessionKey=x5eAwqzbVehBOP7QHfrjpwr9eYtLiHJt7TZFj0uhUMUPQ2T7yNdA7rEgOulejHDHYM1ZyCT0pgXo96EwrfVpMA%3D%3D; s.cachemap=22; s.BrowserIDe6a8f1cf-0874-4323-a12f-2bf51bb6dfdd=00ab552e-0bd2-44f6-afb9-cbec94cb4051; s.classic=False; s.CURedir=True; s.DisplayCulture=en-US; s.MFG=True; p.UtcOffset=-120; market=US; mslocale={'u':'pl-pl'}; LPVID=JjZDkxOGFjNzI3ZTFlZmY5; s.Cart={"BaseOffers":null,"Frequency":0,"IWPurchaseUserId":null,"PromotionCodes":null,"IsOfferTransition":false}; s.InNewAdmin=True; at_check=true; p.FirstLoginDateTimeUtc=id=-172832015&value=Oct_14_2015; s.ImpressionId=9c5222af-0f0a-4464-886a-ebc7eee1b188; p.FirstBillingYear=id=-172832015&value=2015; s.DefaultBillingMonth=08/20/2021 20:04:06; s.DCLoc=weuprod; p.TenantCulture=ceb371f6-8745-4876-a040-69f2d10a9d1a::pl-PL; mbox=PC#7383f384d21f43ef9a0d9d5c273578ed.37_0#1664248950|session#020faa6548144c6486e3597fd3298e30#1630064111; LPSID-60270350=HKOY_Iw3QjSJ9ijUKJt52Q; s.SessID=8798a6f9-b245-4f5e-99ed-1b78809d75a1; RootAuthToken=AwAAABoxMS8yNi8yMDIxIDE5OjA1OjU2ICswMDowMOoLMC5BUzhBOW5HenprV0hka2lnUUdueTBRcWRHZ1lBQUFBQUFQRVB6Z0FBQUFBQUFBQXZBQzguQWdBQkFBQUFBQUQtLURMQTNWTzdRcmRkZ0pnN1dldnJBZ0RzX3dRQTlQOHJfczBGMDYxZ053MTBrZllsVmtYOHZnYVZIbWFUWUVDbXltT2dzMWlGTFRsQXZ4VS1lYjdScjg2U2QwYXZSY05tNGpIcWhlMDBrYmJuWUh3NEtURnVHalN4cklQRTZjamlUUXJKYmRMMXNzcVpBVTZpUE94eVM1aHQzNEN0M1p0bWV1Y1BXaWNsZFdUNmlwVDJtT3JNS2RDaVZLUS1iRGctSHRjUjc3R094eU1hM2pIclBWOXZkOVFqdEdBY1g0azNqalZtRHJhODVFWFRKRjk3TFFEVUxGcWw1SUhyTy1ROHVfQ1RneUFjeHdjVml0anNBRllyUVFwTTFZM3hJRTFxcF9BXzZzeUZuRUFQVm9kUDIzSkUwLWtHaWNvYUowOXhRSlpvMEdTM2IwSzJtUWdFMTYybUUzRGdDQ3lna01qRjlBNko2b0otY09pZ25JOFVLNGg0MnAzVDlSeEdEbVZrTEM4LVJUbHVBUkVNS1JmTElsbFNXZVota1JHU1pZVExLY3IxUG5NN2pVSjBGZDZUODl5LTE1cFVSaWdFdHZKLTJtUms0S2s0ejUwTUtEUzIwejQzMHV3b19Ra1N6el81QnpyeFU5dnY1aGZGai1aOU5TSC16eEtKWHpaUUxua2toMElMd2NVc0xQVmdDVndPa3ZYTlRLazdNWmNUdHcyLVBOVFV2bTJha0p0ZjNQM3hIZExNX3RzdFlZUmxjVUlSOVBWWGFOeXpRTWlvX0kxU1lCanh6bUtpM2tfdVBvdXd1bzYycDltZlFOeUlrOWotX2ctQ2RlSVA4WVBsOHRnekhNMXJWTGlBWjdLUVlDZHpBNXRBMll5LVFFZEYyYi1VcDZqblFmeExoRnJBM3ZleWpRck1MUmJCdVVGVUxscUVMODZSRE16eld1eENoSGh1eEdzSTZaYnFPek9BdUJBSHpjRGxuNHN1MEpEQ3hmc3hidWhocTk4RHNHdWQ4MnhJNU1zYWtEZlZfYUN4ZXV0NzRPR1A2SnkyVGtaLVRJNWcyc2xpM2hEOW14VWRVNmVNdG1HQTVXeWs4dG9JaG1oMXVtMWNNVTBsblpFOUhOZDJKMzJHbk1LaU5Mejg4dktfeW5Va1llY2NwOEcwNUR4aUtpSGkzVUZqNm01eXFBSnVneFRTYTZ6SHBGWHF0SVFfNXZjTHJjM2JhR1paMm4xWjdBTEhZd3hxN3NSSmFNUTROZnFpRnNlT2pqR1JaNjI1VU5kdWxFTGJaLUp1aFpiS05uTG1wQlB5UkNSMEp2czlpekdRRU1ReXhhMzJKWHEzaGduQi1TcGd5N1lLS1dmYXN2MmVhV0hibUctR1hxQ2N4THZKbUV4WHM5VXVBd2NzLU1pc19wUmNzNTdlWmxHZ0xPTlpNUGxvNGQ5Vmh1b0tLanQ4dHdlRDA1VXZ5VGIzaFhjSjFBVG41aVhQampwaEFVaEhPNS01ZXg0cDkyakVmcy13SUhRV2ZURE1aZy1Ca0diVU85LUQtd0NSVExqVm1QV0k2TUFpM0h3cWxvZXZ2M3doWE80bm9NQmVMQlRsNHRiT2QyZXZocXlPaTNudHpNTzVBMFoxbzFDZ1NCMkozVkxRbFpDR2ZocHdHd1kwT3JGb25kVExIcG5LUnBLOE1YdkRLdldSd0tqUl9CSEVPU0IxNlVQOHg2SERZV1BUaGRWRDJFamVtbWpZWmgxaVF0cnZobjBFYTJiRE1yekVHcjFNTlFROGlPVENnLXlVWk1YeVVobXJYMklra05rVExZWWYzRU1ndHBGRUhDWHRTZWpueVphZ1JvcGh0M05yUTJ2MWFXOFE4Q1pfR21XcGs5dkE2MXR4MUhKZHExY3FldE1GM3FpbFAxSTJjd09RZFdNZy1OT2cA; s.LoginUserTenantId=kyHaNehhz9jpR+09ZPKS4DynUHwzw7PquEHQY+SZE6vRWhg+ZenTYDg29pApIbkUamgN9MVhZ/VbADv3Wr2Xnn3vQCRp3hHGvLU4EDcKBxLdi/J1UCSJ5YS6JobJ+hPsanTiHrdOwR5fSMI4rt1cJg==; UserIndex=H4sIAAAAAAAEAGNkYGBgBGI2IGYCsfWBBINkQVFVam5lcU5iuV52TmWxQ2pZfklqsl5BDjNQVtjIwMhQ18BC18gyxNDCysDUytSCBaSNFYTdEnOKU0HGqSSlJJmaGyUn6RqnGFvomqSlpukmmVmY6VqmWVgkm6akmKYYmYK0AQDFS8PlhAAAAA%3D%3D; OIDCAuthCookie=%2BSKNwKbOp3tUWr2%2BSTWrgME8BQoKkh7P55ishMUl3EwwalLmRnorz031%2FWXRh2gszg0uE20Nfdak8qB1vtHFOz%2FF24zwiQa0THjlt6pnBbz9vyhA4iuJNzvwt3XjSmId3Da9X8P4nQ%2FUJE%2BssHTASvNOEnPrMWvrBm1z0222f3GgiWQ2v9ArrbeXOxWvV8Me%2BUPnQ%2FEDui%2B940hO6htSDcG3h46GZJBbFSysbtE5dgQgPhixil29dQE7npcsCycLBgv%2FwypJXh%2BKq5mD%2BpfJwtNbDmvuxz9eQYZUBPWvriBHva6on%2FRXp19xAX8K%2BMwukPVYtCbqeaLP5LCK%2B1pQAFFa4GtKOY1OxVmIUcTSg88Jf0DGWYkR8CzFINgWxNhsVXRV%2BIWjz2OF6irsv%2F3L18zNFxluVlL41uzho5gqlI%2BTmgwtO%2FtWwMDqfZkdVYaufr%2B6DF6alJHFTGEb67sTmlMGeBI1w%2BeHc9Z3alFqLqcBVxg8XB88pUxzF6Dj7CGySByFC2lg%2FZaZeNgFx4BYYUa4o2rYpWhjVhYcXxixSOmFaqZhEEOCdrgB5qoTdoGMPCpoj22C9g6yow1l51GANTK9ujTRGS5LYLFA7R%2BSIcQNM50zDU1wAgoAl%2BnWQUjzK5D9XlBMhSovq7Dd4hXFW%2BnsQp2xKJL1AcE89FVKhlC3LKiwNHKSmDz2mlvYHyVRasm1jbel1BY0dKd%2F1ZMd5aKg94GEXeMdwpyyyg573HuFbCnPBd4TYdeMPg6siaMj%2Bwt%2BcZfZGbm6A9xfaq82vzUP3AU0lmz%2BYxaPT3e4fqmQVNxw0FvfPoIjy3SHaQryqseAP0LVwC6GXFOH4yEGtC63Y%2F%2FVOaE0LXbhhN10ejkQbwZGDtpUiO3%2FBihlUTVAEvYlWEnNd1Mjnr1uRl0JPknEUsbFe4gQNi7UIZo4T7vjDeNGom53bp%2BFryaNb9jCQi3jp1f9CU2xli%2B6pH%2B%2BuFvnODrDE5tJUHE3v13LljzGCbLXO%2B91K17KzIfiAoKAYnZPWNsFvgp2iUPbNRqax%2FBBtF7Zv%2ByofRex3OxXAR1kQCUcmxzItYeLBMNkTKY4B6L8w84U8Cmem%2Fnets2xdzNcYnu30qJkwHIckG7M5A4bpObrscZQ34XOiZ3%2FaLb3nAt8GhOgRe51XbzqVX86NeE9iDBhis%2FBG0JY2Ux3LZO%2B1FwKMjLO2a60OnJIRgORbjSaJV3aJiCkBlbpQ4PX5zXji41h4wSlVzYNsy2QlGJVpDfqbfqWl2DAH5JQKobBmlcp7bn3l6GGXR0XUcJJ6Qi4ZmXzofMLlc6zRhKe15cBp0zmzAlTd4%2BH6kbcduITep6h3NdjDmwFoTz96XY%2BzCE3HxgL1zrVW8qr6WYqSGbaaSqVMNKoM6Z33CRB%2BFUoVpZjHRl2kAxVdvRc3zLSI10M23PELrDur56TDDpgfi2ERY1DjNnS8BaucCs5Rqh35QQPLGmumMRprtrURFitfRlLgl7ZSyOW62ScyxxclityxBeY8NA%2Fi8IPFGrWSSrSVjAtTsJVjRUX5GHIANuZL9YImsVnrShvbyrbxMmSxfJ45pAo8mqX%2FGwnOg7V8TabzvYWuWZvUwpM%2BFktbNaQ960iRoR00UYI0IhC4hnoAAnlKeguUGq8aHuEUywllI%2FwYyjlRCXkx7znLCMj%2FuG7x7acGAStDg%2F97Q8ImojZWT9y9oD6QIPQLI7%2B4vqxBht2ZHxZMxr2WsoAUn1cB7WvPtIyJA43T36AL%2F64X0rg8Kj0nMsC3eQzoJGaWB9XSJzogLtCZAQ1W5%2BLPCIpsWL3IsL9J2gjivl%2BKNH8kDxckxpTFB69Rkau0%2BgjXXiyHEQEd6%2FDtOeRMI3MOWg%2FGzjVbVNxMJock%2B%2FpoAf%2FPgtkV8w%3D; s.DmnHQT=08/29/2021 18:06:00; s.DmnRQT=08/29/2021 18:06:07; s.DmnSOQT=08/29/2021 18:06:07; p.LastLoginDateTimeUtc=Aug_29_2021_18_06_00; MicrosoftApplicationsTelemetryDeviceId=f7e3a469-8044-4a21-ad55-69ce7f6b4086; MicrosoftApplicationsTelemetryFirstLaunchTime=2021-08-29T18:10:03.226Z


#>
