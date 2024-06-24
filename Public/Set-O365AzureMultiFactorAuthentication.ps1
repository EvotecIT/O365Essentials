function Set-O365AzureMultiFactorAuthentication {
    <#
    .SYNOPSIS
    Configures Multi-Factor Authentication (MFA) settings for an Office 365 tenant.

    .DESCRIPTION
    This function allows administrators to modify various settings related to Multi-Factor Authentication (MFA) for their Office 365 tenant. It includes options such as account lockout policies, fraud alert configurations, and bypass settings.

    .PARAMETER Headers
    Specifies the headers for the API request, typically including authorization details.

    .PARAMETER AccountLockoutDurationMinutes
    Specifies the duration in minutes that an account remains locked after reaching the threshold of failed MFA attempts.

    .PARAMETER AccountLockoutResetMinutes
    Defines the time period in minutes after which the count of failed MFA attempts is reset.

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
    Recipient's One-Time Email Addresses for Bypass

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
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[int]] $AccountLockoutDurationMinutes,
        [nullable[int]] $AccountLockoutCounterResetMinutes,
        [nullable[int]] $AccountLockoutDenialsToTriggerLockout,
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

    $Uri = "https://main.iam.ad.ext.azure.com/api/MultiFactorAuthentication/TenantModel?licenseKey="
    $Body = [ordered] @{}
    <#
        #tenantId                        = $CurrentSettings #: ceb371f6
        #licenseKey                      = $CurrentSettings #:
        #customerId                      = $CurrentSettings #:
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
    #>
    if ($PSBoundParameters.ContainsKey('AccountLockoutDurationMinutes')) {
        $Body['AccountLockoutDurationMinutes'] = $AccountLockoutDurationMinutes
    }
    if ($PSBoundParameters.ContainsKey('AccountLockoutCounterResetMinutes')) {
        $Body['AccountLockoutResetMinutes'] = $AccountLockoutCounterResetMinutes
    }
    if ($PSBoundParameters.ContainsKey('AccountLockoutDenialsToTriggerLockout')) {
        $Body['AccountLockoutThreshold'] = $AccountLockoutDenialsToTriggerLockout
    }
    if ($PSBoundParameters.ContainsKey('BlockForFraud')) {
        $Body['BlockForFraud'] = $BlockForFraud
    }
    if ($PSBoundParameters.ContainsKey('EnableFraudAlert')) {
        $Body['EnableFraudAlert'] = $EnableFraudAlert
    }
    if ($PSBoundParameters.ContainsKey('FraudCode')) {
        $Body['FraudCode'] = $FraudCode
    }
    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PATCH -Body $Body
}
