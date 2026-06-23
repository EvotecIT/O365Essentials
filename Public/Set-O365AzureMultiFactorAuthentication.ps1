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
    $CurrentSettings = Get-O365AzureMultiFactorAuthentication -Headers $Headers
    if (-not $CurrentSettings -or [string]::IsNullOrWhiteSpace($CurrentSettings.licenseKey)) {
        Write-Warning -Message 'Set-O365AzureMultiFactorAuthentication - Current MFA settings or license key could not be read.'
        return
    }

    $Uri = "https://main.iam.ad.ext.azure.com/api/MultiFactorAuthentication/TenantModel?licenseKey=$([uri]::EscapeDataString($CurrentSettings.licenseKey))"
    $Body = [ordered] @{
        tenantId                         = $CurrentSettings.tenantId
        licenseKey                       = $CurrentSettings.licenseKey
        customerId                       = $CurrentSettings.customerId
        accountLockoutDurationMinutes    = $CurrentSettings.accountLockoutDurationMinutes
        accountLockoutResetMinutes       = $CurrentSettings.accountLockoutResetMinutes
        accountLockoutThreshold          = $CurrentSettings.accountLockoutThreshold
        allowPhoneMenu                   = $CurrentSettings.allowPhoneMenu
        blockForFraud                    = $CurrentSettings.blockForFraud
        callerId                         = $CurrentSettings.callerId
        defaultBypassTimespan            = $CurrentSettings.defaultBypassTimespan
        enableFraudAlert                 = $CurrentSettings.enableFraudAlert
        fraudCode                        = $CurrentSettings.fraudCode
        fraudNotificationEmailAddresses  = $CurrentSettings.fraudNotificationEmailAddresses
        oneTimeBypassEmailAddresses      = $CurrentSettings.oneTimeBypassEmailAddresses
        pinAttempts                      = $CurrentSettings.pinAttempts
        sayExtensionDigits               = $CurrentSettings.sayExtensionDigits
        smsTimeoutSeconds                = $CurrentSettings.smsTimeoutSeconds
        caches                           = @($CurrentSettings.caches)
        notifications                    = $CurrentSettings.notifications
        notificationEmailAddresses       = @($CurrentSettings.notificationEmailAddresses)
        greetings                        = @($CurrentSettings.greetings)
        blockedUsers                     = @($CurrentSettings.blockedUsers)
        bypassedUsers                    = @($CurrentSettings.bypassedUsers)
        groups                           = @($CurrentSettings.groups)
        etag                             = $CurrentSettings.etag
    }
    $RequestedChanges = [ordered] @{}
    if ($PSBoundParameters.ContainsKey('AccountLockoutDurationMinutes')) {
        $Body.accountLockoutDurationMinutes = $AccountLockoutDurationMinutes
        $RequestedChanges.accountLockoutDurationMinutes = $AccountLockoutDurationMinutes
    }
    if ($PSBoundParameters.ContainsKey('AccountLockoutCounterResetMinutes')) {
        $Body.accountLockoutResetMinutes = $AccountLockoutCounterResetMinutes
        $RequestedChanges.accountLockoutResetMinutes = $AccountLockoutCounterResetMinutes
    }
    if ($PSBoundParameters.ContainsKey('AccountLockoutDenialsToTriggerLockout')) {
        $Body.accountLockoutThreshold = $AccountLockoutDenialsToTriggerLockout
        $RequestedChanges.accountLockoutThreshold = $AccountLockoutDenialsToTriggerLockout
    }
    if ($PSBoundParameters.ContainsKey('BlockForFraud')) {
        $Body.blockForFraud = $BlockForFraud
        $RequestedChanges.blockForFraud = $BlockForFraud
    }
    if ($PSBoundParameters.ContainsKey('EnableFraudAlert')) {
        $Body.enableFraudAlert = $EnableFraudAlert
        $RequestedChanges.enableFraudAlert = $EnableFraudAlert
    }
    if ($PSBoundParameters.ContainsKey('FraudCode')) {
        $Body.fraudCode = [string] $FraudCode
        $RequestedChanges.fraudCode = [string] $FraudCode
    }

    if ($RequestedChanges.Count -eq 0) {
        Write-Warning -Message 'Set-O365AzureMultiFactorAuthentication - No MFA setting was specified.'
        return
    }

    if ($PSCmdlet.ShouldProcess($Uri, 'Update legacy MFA tenant model')) {
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PATCH -Body $Body
        $UpdatedSettings = Get-O365AzureMultiFactorAuthentication -Headers $Headers
        foreach ($PropertyName in $RequestedChanges.Keys) {
            if ($UpdatedSettings.$PropertyName -ne $RequestedChanges[$PropertyName]) {
                Write-Warning -Message "Set-O365AzureMultiFactorAuthentication - The service did not persist '$PropertyName'. This legacy portal endpoint may no longer accept tenant model writes."
            }
        }
    }
}
