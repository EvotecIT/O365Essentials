function Set-O365AzureMultiFactorAuthentication {
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