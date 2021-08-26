function Set-O365MultiFactorAuthentication {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Headers
    Parameter description

    .PARAMETER AccountLockoutDurationMinutes
    Minutes until account is automatically unblocked

    .PARAMETER AccountLockoutResetMinutes
    Minutes until account lockout counter is reset

    .PARAMETER AccountLockoutThreshold
    Number of MFA denials to trigger account lockout

    .PARAMETER AllowPhoneMenu
    Parameter description

    .PARAMETER BlockForFraud
    Automatically block users who report fraud

    .PARAMETER CallerId
    MFA caller ID number (US phone number only)

    .PARAMETER DefaultBypassTimespan
    Default one-time bypass seconds

    .PARAMETER EnableFraudAlert
    Allow users to submit fraud alerts

    .PARAMETER FraudCode
    Code to report fraud during initial greeting

    .PARAMETER FraudNotificationEmailAddresses
    Recipient's Email Address

    .PARAMETER OneTimeBypassEmailAddresses
    Parameter description

    .PARAMETER PinAttempts
    Number of PIN attempts allowed per call

    .PARAMETER SayExtensionDigits
    Parameter description

    .PARAMETER SmsTimeoutSeconds
    Two-way text message timeout seconds

    .PARAMETER Caches
    Parameter description

    .PARAMETER Notifications
    Parameter description

    .PARAMETER NotificationEmailAddresses
    Parameter description

    .PARAMETER Greetings
    Parameter description

    .PARAMETER BlockedUsers
    Parameter description

    .PARAMETER BypassedUsers
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    Based on: https://portal.azure.com/#blade/Microsoft_AAD_IAM/MultifactorAuthenticationMenuBlade/GettingStarted/fromProviders/

    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[int]] $AccountLockoutDurationMinutes,
        [nullable[int]] $AccountLockoutResetMinutes,
        [nullable[int]] $AccountLockoutThreshold,
        #$AllowPhoneMenu,
        [nullable[bool]] $BlockForFraud,
        #$CallerId,
        #$DefaultBypassTimespan,
        [nullable[bool]] $EnableFraudAlert,
        [nullable[int]] $FraudCode
        #$FraudNotificationEmailAddresses,
        #$OneTimeBypassEmailAddresses,
        #$PinAttempts,
        #$SayExtensionDigits,
        #$SmsTimeoutSeconds,
        #$Caches,
        #$Notifications,
        #$NotificationEmailAddresses
        #$Greetings                      ,
        #$BlockedUsers                   ,
        #$BypassedUsers
    )
    #$Uri = "https://main.iam.ad.ext.azure.com/api/MultiFactorAuthentication/GetOrCreateExpandedTenantModel?tenantName=Evotec"
    # $Uri = "https://main.iam.ad.ext.azure.com/api/MultiFactorAuthentication/GetOrCreateExpandedTenantModel"

    # Whatever I do, doesn't work!

    $Uri = "https://main.iam.ad.ext.azure.com/api/MultiFactorAuthentication/TenantModel"
    $Body = [ordered] @{
        #tenantId                        = $CurrentSettings #: ceb371f6
        #licenseKey                      = $CurrentSettings #:
        #customerId                      = $CurrentSettings #:
        AccountLockoutDurationMinutes   = $accountLockoutDurationMinutes #:
        AccountLockoutResetMinutes      = $accountLockoutResetMinutes #:
        AccountLockoutThreshold         = $accountLockoutThreshold #:
        AllowPhoneMenu                  = $allowPhoneMenu #: False
        BlockForFraud                   = $BlockForFraud #: False
        CallerId                        = $callerId #: 8553308653
        DefaultBypassTimespan           = $defaultBypassTimespan #: 300
        EnableFraudAlert                = $EnableFraudAlert #: True
        FraudCode                       = $fraudCode #: 0
        FraudNotificationEmailAddresses = $fraudNotificationEmailAddresses #:
        OneTimeBypassEmailAddresses     = $oneTimeBypassEmailAddresses #:
        PinAttempts                     = $pinAttempts #:
        SayExtensionDigits              = $sayExtensionDigits #: False
        SmsTimeoutSeconds               = $smsTimeoutSeconds #: 60
        #caches                          = $caches #: {}
        Notifications                   = $notifications #:
        NotificationEmailAddresses      = $notificationEmailAddresses #: {}
        #greetings                       = $greetings #: {}
        #blockedUsers                    = $blockedUsers #: {}
        #bypassedUsers                   = $bypassedUsers #: {}
        #groups                          = $groups
        #etag                            = $etag
    }

    Remove-EmptyValue -Hashtable $Body
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PATCH -Body $Body
    $Output
}

<#
/api/MultiFactorAuthentication/TenantModel?licenseKey=

PATCH https://main.iam.ad.ext.azure.com/api/MultiFactorAuthentication/TenantModel?licenseKey= HTTP/1.1
Host: main.iam.ad.ext.azure.com
Connection: keep-alive
Content-Length: 67
x-ms-client-session-id: 9fb6b21894f14f5786814508d7462a51
Accept-Language: en
etag: 1629994960.340884_c0565cb3
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiI3NDY1ODEzNi0xNGVjLTQ2MzAtYWQ5Yi0yNmUxNjBmZjBmYzYiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9jZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEvIiwiaWF0IjoxNjI5OTk3MTgwLCJuYmYiOjE2Mjk5OTcxODAsImV4cCI6MTYzMDAwMTA4MCwiYWNyIjoiMSIsImFpbyI6IkFWUUFxLzhUQUFBQTYrNGZseVJBNU5PdUxBQSt3czI2Y0M3WG1STmhwVW1LajJjWjhDalhTK2thcjN5YytyUXEvOHQ1eXFBT0Rxa2EwMXR3M0Zkc0RSQW9UQ0trb1lIdUQzRWYvZTh3NjdVNHFJMlFkU1FEWEl3PSIsImFtciI6WyJyc2EiLCJtZmEiXSwiYXBwaWQiOiJjNDRiNDA4My0zYmIwLTQ5YzEtYjQ3ZC05NzRlNTNjYmRmM2MiLCJhcHBpZGFjciI6IjIiLCJkZXZpY2VpZCI6IjNhZTIyNzI2LWRmZDktNGFkNy1hODY1LWFhMmI1MWM2ZTBmZiIsImZhbWlseV9uYW1lIjoiS8WCeXMiLCJnaXZlbl9uYW1lIjoiUHJ6ZW15c8WCYXciLCJpcGFkZHIiOiI4OS43Ny4xMDIuMTciLCJuYW1lIjoiUHJ6ZW15c8WCYXcgS8WCeXMiLCJvaWQiOiJlNmE4ZjFjZi0wODc0LTQzMjMtYTEyZi0yYmY1MWJiNmRmZGQiLCJvbnByZW1fc2lkIjoiUy0xLTUtMjEtODUzNjE1OTg1LTI4NzA0NDUzMzktMzE2MzU5ODY1OS0xMTA1IiwicHVpZCI6IjEwMDMwMDAwOTQ0REI4NEQiLCJyaCI6IjAuQVM4QTluR3p6a1dIZGtpZ1FHbnkwUXFkR29OQVM4U3dPOEZKdEgyWFRsUEwzend2QUM4LiIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInN1YiI6ImVvU3lzNXlDNmJvWmQ5a21YRXVNSWl5YUxhX1g1VTdmSWZJck1DV0hORjQiLCJ0ZW5hbnRfcmVnaW9uX3Njb3BlIjoiRVUiLCJ0aWQiOiJjZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEiLCJ1bmlxdWVfbmFtZSI6InByemVteXNsYXcua2x5c0Bldm90ZWMucGwiLCJ1cG4iOiJwcnplbXlzbGF3LmtseXNAZXZvdGVjLnBsIiwidXRpIjoiT0VwOHBwUl93RWFLZGxUMmpUTWlBQSIsInZlciI6IjEuMCIsIndpZHMiOlsiNjJlOTAzOTQtNjlmNS00MjM3LTkxOTAtMDEyMTc3MTQ1ZTEwIiwiYjc5ZmJmNGQtM2VmOS00Njg5LTgxNDMtNzZiMTk0ZTg1NTA5Il0sInhtc190Y2R0IjoxNDQ0ODQ1NTQ0fQ.OMVGz1zvr_IzPoa13Pb-uVWG6-ov87D2rQjCGYLgiWQl4_lcuFN9p9Z5kUW7ej8f1Dqw27WRvVFLDd_M682FI7skkddafUgDPuerMuMENiQYWeaEjylnlgEPgGk3t95Haf1OoHCOQZz8rR1wovAJnMABA5UZwuIkvn0Dl3l_Co7Aj8AE4-7BANUnqAUxEc97UhUejvwmldmOQN-KESwsthGa6ayjloMkh2ME0En_ME1QBJ_hpdAGFlpcsrSOCPUjnqemZwxXH1ceGdyb9HRky_oQIqNlnn073Cyoa48vJ33n3BCyWcYwhpC8NLWJSTnh2oOisdnwUBkaw5BVUDAP7w
x-ms-effective-locale: en.en-us
Content-Type: application/json
Accept: */*
x-ms-client-request-id: 983affdb-0b06-4095-b652-048e18d8d010
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.78
Origin: https://portal.azure.com
Sec-Fetch-Site: same-site
Sec-Fetch-Mode: cors
Sec-Fetch-Dest: empty
Accept-Encoding: gzip, deflate, br

{"AccountLockoutResetMinutes":5,"AccountLockoutDurationMinutes":20}
#>
