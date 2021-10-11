function Set-O365AzureProperties {
    <#
    .SYNOPSIS
    Changes the properties of Azure Active Directory (Azure AD) for the current tenant.

    .DESCRIPTION
    Changes the properties of Azure Active Directory (Azure AD) for the current tenant - available at URL: https://aad.portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Properties

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

    .PARAMETER DisplayName
    Name of the tenant

    .PARAMETER TechnicalContact
    Technical contact for the tenant

    .PARAMETER GlobalPrivacyContact
    Global privacy contact for the tenant

    .PARAMETER PrivacyStatementURL
    Privacy statement URL for the tenant

    .EXAMPLE
    Set-O365AzureProperties -Verbose -Name "Evotec Test" -TechnicalContact 'test@evotec.pl' -GlobalPrivacyContact 'test@evotec.pl' -PrivacyStatementURL "https://test.pl" -WhatIf

    .EXAMPLE
    Set-O365AzureProperties -Verbose -Name "Evotec" -TechnicalContact 'test@evotec.pl' -GlobalPrivacyContact $null -PrivacyStatementURL $null -WhatIf

    .NOTES
    Please note that Technical Contact cannot be removed. It always needs to be set.

    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [alias('Name')][string] $DisplayName,
        [string] $TechnicalContact,
        [string] $GlobalPrivacyContact,
        [string] $PrivacyStatementURL
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/Directories"

    $CurrentSettings = Get-O365AzureProperties -Headers $Headers -NoTranslation
    if ($CurrentSettings) {
        $Body = @{
            objectId                               = $CurrentSettings.objectId                              #
            displayName                            = $CurrentSettings.displayName                           #
            companyLastDirSyncTime                 = $CurrentSettings.companyLastDirSyncTime                #
            dirSyncEnabled                         = $CurrentSettings.dirSyncEnabled                        #
            replicationScope                       = $CurrentSettings.replicationScope                      #
            dataCenterLocation                     = $CurrentSettings.dataCenterLocation                    #
            countryLetterCode                      = $CurrentSettings.countryLetterCode                     #
            countryName                            = $CurrentSettings.countryName                           #
            preferredLanguage                      = $CurrentSettings.preferredLanguage                     #
            preferredLanguages                     = $CurrentSettings.preferredLanguages                    #
            verifiedDomains                        = $CurrentSettings.verifiedDomains                       #
            globalAdminCanManageAzureSubscriptions = $CurrentSettings.globalAdminCanManageAzureSubscriptions#
            privacyProfile                         = $CurrentSettings.privacyProfile                        #
            technicalNotificationMails             = $CurrentSettings.technicalNotificationMails            #
        }
        $Setting = $false
        if ($PSBoundParameters.ContainsKey('DisplayName')) {
            $Body.displayName = $DisplayName
            $Setting = $true
        }
        if ($PSBoundParameters.ContainsKey('TechnicalContact')) {
            if ($TechnicalContact) {
                $Body.technicalNotificationMails = @(
                    $TechnicalContact
                )
            } else {
                Write-Warning -Message "Set-O365AzureProperties - Using empty/null Technical Contact is not supported."
                return
                $Body.technicalNotificationMails = ''
            }
            $Setting = $true
        }
        if ($PSBoundParameters.ContainsKey('GlobalPrivacyContact')) {
            $Body.privacyProfile.contactEmail = $GlobalPrivacyContact
            $Setting = $true
        }
        if ($PSBoundParameters.ContainsKey('PrivacyStatementURL')) {
            $Body.privacyProfile.statementUrl = $PrivacyStatementURL
            $Setting = $true
        }
        if ($Setting) {
            $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body
        } else {
            Write-Warning -Message "Set-O365AzureProperties - No settings to update"
        }
    }
}

<#

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36 Edg/94.0.992.38"
Invoke-WebRequest -UseBasicParsing -Uri "https://main.iam.ad.ext.azure.com/api/Directories" `
    -Method "PUT" `
    -WebSession $session `
    -Headers @{
    "x-ms-client-session-id" = "2c99a939029b4409ac6028764b17bb03"
    "Accept-Language"        = "en"
    "Authorization"          = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Imwzc1EtNTBjQ0g0eEJWWkxIVEd3blNSNzY4MCIsImtpZCI6Imwzc1EtNTBjQ0g0eEJWWkxIVEd3blNSNzY4MCJ9.eyJhdWQiOiI3NDY1ODEzNi0xNGVjLTQ2MzAtYWQ5Yi0yNmUxNjBmZjBmYzYiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC84YTg1MjYxMi1lZjc5LTQzNDEtOTdkNy1hMTliMmZhNjRjY2UvIiwiaWF0IjoxNjMzOTYzMDE2LCJuYmYiOjE2MzM5NjMwMTYsImV4cCI6MTYzMzk2NjkxNiwiYWNyIjoiMSIsImFpbyI6IkFWUUFxLzhUQUFBQW5xenkxTURoekJveEhscXVWb3pCRzB4MWsranppc3ZxZ05uOFdYTkk2eXYwYitpMWVja2tNWlJFaDYrMW1KYktSazR6azBxcDBZSjArSnZLK3FuakNQSW9YVHg3SHFERVltcU5LVTNCMDZzPSIsImFtciI6WyJwd2QiLCJtZmEiXSwiYXBwaWQiOiJjNDRiNDA4My0zYmIwLTQ5YzEtYjQ3ZC05NzRlNTNjYmRmM2MiLCJhcHBpZGFjciI6IjIiLCJmYW1pbHlfbmFtZSI6IktseXMiLCJnaXZlbl9uYW1lIjoiUHJ6ZW15c2xhdyIsImlwYWRkciI6Ijg5Ljc3LjEwMi4xNyIsIm5hbWUiOiJQcnplbXlzbGF3IEtseXMgQ0FETSIsIm9pZCI6ImM5NTY5ODhmLTZlZjMtNDEwZi1hNjQyLWVlMTM0ZWY3MjdjMyIsInB1aWQiOiIxMDAzMjAwMTIwNTc0MjdCIiwicmgiOiIwLkFWOEFFaWFGaW5udlFVT1gxNkdiTDZaTXpvTkFTOFN3TzhGSnRIMlhUbFBMM3p4ZkFBUS4iLCJzY3AiOiJ1c2VyX2ltcGVyc29uYXRpb24iLCJzdWIiOiJleUNWMDRhd1dqS0VHMnNUc0dxSmtHSjlZUWJCRzNYazFKcTBpam1CTkc4IiwidGVuYW50X3JlZ2lvbl9zY29wZSI6IkVVIiwidGlkIjoiOGE4NTI2MTItZWY3OS00MzQxLTk3ZDctYTE5YjJmYTY0Y2NlIiwidW5pcXVlX25hbWUiOiJDQURNX0paNVFAZXVyb2ZpbnN0ZXN0My5vbm1pY3Jvc29mdC5jb20iLCJ1cG4iOiJDQURNX0paNVFAZXVyb2ZpbnN0ZXN0My5vbm1pY3Jvc29mdC5jb20iLCJ1dGkiOiJaeEtwdlVRRGVrcWpFV1FucEZVcEFRIiwidmVyIjoiMS4wIiwid2lkcyI6WyI2MmU5MDM5NC02OWY1LTQyMzctOTE5MC0wMTIxNzcxNDVlMTAiLCJiNzlmYmY0ZC0zZWY5LTQ2ODktODE0My03NmIxOTRlODU1MDkiXSwieG1zX3RjZHQiOjE1ODYyNzExNDF9.W0pZUmLN4Xj-o-dWSfJKF1HG08wxvuQEM-mW88EnSKAIVSI6IWAOsWAUWDMdDwuy9DzjjB9u3F_V9ahFWid0t-mn5i0jzswEeg5BanDJOs3sz4KZeKYzXe4Q5eastFKvw526ATAhoQD-lCZ00w7S82vBOB_f5jol_mtMCWopANu5OonTX9glcz2mHxj1_vjNM5NZeOYqCc5Lss8d2XV5ghqauW-mLcLd3hVI6eX_RBKpTm7Y2vgc4EyAte35iGUgPveeFAmF8DyWm1V9BAFqD7lo2dopgXxt3rWXUCw4Zixt6u3fDxpUoIEoAvsInGK-Q8rFbosNyk78Bg6Ja7EzQg"
    "x-ms-effective-locale"  = "en.en-us"
    "Accept"                 = "*/*"
    "Referer"                = ""
    "x-ms-client-request-id" = "c465c06e-6937-40ba-88aa-ba63dc35c01e"
} `
    -ContentType "application/json" `
    -Body ([System.Text.Encoding]::UTF8.GetBytes("

    {`"objectId`":`"8a852612-ef79-4341-97d7-a19b2fa64cce`",
    `"displayName`":`"Eurofins GSC France`",
    `"companyLastDirSyncTime`":`"2021-10-11T14:42:59Z`",
    `"dirSyncEnabled`":true,`"replicationScope`":`"EU`",
    `"dataCenterLocation`":`"EU Model Clause compliant datacenters`",
    `"countryLetterCode`":`"FR`",
    `"countryName`":`"France`",`"preferredLanguage`":`"en`",
    `"preferredLanguages`":[{`"displayName`":`"English`",`"languageCode`":`"en`"},
    {`"displayName`":`"fran$([char]231)ais`",`"languageCode`":`"fr`"}],
    `"verifiedDomains`":[{`"id`":`"000520000819CC42`",`"type`":`"Managed`",`"name`":
    `"eurofinstest3.onmicrosoft.com`",`"initial`":true,`"isDirSyncExchangeOnlineDomain`":false},
    {`"id`":`"000520000866EC97`",`"type`":`"Managed`",`"name`":`"eurofinstest3.mail.onmicrosoft.com`",
    `"initial`":false,`"isDirSyncExchangeOnlineDomain`":true},{`"id`":`"000520000A1A4828`",`"type`":`"Managed`",
    `"name`":`"eurofins-test.com`",`"initial`":false,`"isDirSyncExchangeOnlineDomain`":false}],
    `"globalAdminCanManageAzureSubscriptions`":false,
    `"privacyProfile`":{`"contactEmail`":`"`",`"statementUrl`":`"https://eurofins.com`"},
    `"technicalNotificationMails`":[`"aurelienlesage@eurofins.com`"]}"))

#>