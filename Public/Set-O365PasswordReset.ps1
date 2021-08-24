function Set-O365PasswordReset {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[int]] $EnablementType                       , # = $CurrentSettings.enablementType #: 1
        [nullable[int]]$NumberOfAuthenticationMethodsRequired, # = $CurrentSettings.numberOfAuthenticationMethodsRequired #: 1
        [nullable[bool]] $EmailOptionEnabled                   , # = $CurrentSettings.emailOptionEnabled #: True
        [nullable[bool]] $MobilePhoneOptionEnabled             , # = $CurrentSettings.mobilePhoneOptionEnabled #: True
        [nullable[bool]] $OfficePhoneOptionEnabled             , # = $CurrentSettings.officePhoneOptionEnabled #: False
        [nullable[bool]] $SecurityQuestionsOptionEnabled       , # = $CurrentSettings.securityQuestionsOptionEnabled #: False
        [nullable[bool]] $MobileAppNotificationEnabled         , # = $CurrentSettings.mobileAppNotificationEnabled #: False
        [nullable[bool]] $MobileAppCodeEnabled                 , # = $CurrentSettings.mobileAppCodeEnabled #: True
        [nullable[int]]  $NumberOfQuestionsToRegister          , # = $CurrentSettings.numberOfQuestionsToRegister #: 5
        [nullable[int]] $NumberOfQuestionsToReset             , # = $CurrentSettings.numberOfQuestionsToReset #: 3
        [nullable[bool]] $RegistrationRequiredOnSignIn         , # = $CurrentSettings.registrationRequiredOnSignIn #: True
        [nullable[int]]$RegistrationReconfirmIntevalInDays   , # = $CurrentSettings.registrationReconfirmIntevalInDays #: 180
        [nullable[bool]] $SkipRegistrationAllowed              , # = $CurrentSettings.skipRegistrationAllowed #: True
        [nullable[int]] $SkipRegistrationMaxAllowedDays       , # = $CurrentSettings.skipRegistrationMaxAllowedDays #: 7
        [nullable[bool]] $CustomizeHelpdeskLink                , # = $CurrentSettings.customizeHelpdeskLink #: False
        [string] $CustomHelpdeskEmailOrUrl             , # = $CurrentSettings.customHelpdeskEmailOrUrl #:
        [nullable[bool]] $NotifyUsersOnPasswordReset           , # = $CurrentSettings.notifyUsersOnPasswordReset #: True
        [nullable[bool]] $NotifyOnAdminPasswordReset           , # = $CurrentSettings.notifyOnAdminPasswordReset #: True
        [string] $PasswordResetEnabledGroupIds         , # = $CurrentSettings.passwordResetEnabledGroupIds #: {b6cdb9c3-d660-4558-bcfd-82c14a986b56}
        [string] $PasswordResetEnabledGroupName        , # = $CurrentSettings.passwordResetEnabledGroupName #:
        # don't have details about those. needs investigations
        # $securityQuestions                    , # = $CurrentSettings.securityQuestions #: {}
        #$registrationConditionalAccessPolicies, # = $CurrentSettings.registrationConditionalAccessPolicies #: {}
        [nullable[bool]] $EmailOptionAllowed                   , # = $CurrentSettings.emailOptionAllowed #: True
        [nullable[bool]] $MobilePhoneOptionAllowed             , # = $CurrentSettings.mobilePhoneOptionAllowed #: True
        [nullable[bool]] $OfficePhoneOptionAllowed             , # = $CurrentSettings.officePhoneOptionAllowed #: True
        [nullable[bool]] $SecurityQuestionsOptionAllowed       , # = $CurrentSettings.securityQuestionsOptionAllowed #: True
        [nullable[bool]] $MobileAppNotificationOptionAllowed   , # = $CurrentSettings.mobileAppNotificationOptionAllowed #: True
        [nullable[bool]] $MobileAppCodeOptionAllowed            # = $CurrentSettings.mobileAppCodeOptionAllowed #: True
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/PasswordReset/PasswordResetPolicies"

    $CurrentSettings = Get-O365PasswordReset -Headers $Headers

    if ($CurrentSettings.objectId -ne 'default') {
        Write-Warning -Message "Set-O365PasswordReset - Getting current settings failed. Skipping changes."
        return
    }

    $Body = [ordered] @{
        objectId                              = $CurrentSettings.objectId #: default
        enablementType                        = $CurrentSettings.enablementType #: 1
        numberOfAuthenticationMethodsRequired = $CurrentSettings.numberOfAuthenticationMethodsRequired #: 1
        emailOptionEnabled                    = $CurrentSettings.emailOptionEnabled #: True
        mobilePhoneOptionEnabled              = $CurrentSettings.mobilePhoneOptionEnabled #: True
        officePhoneOptionEnabled              = $CurrentSettings.officePhoneOptionEnabled #: False
        securityQuestionsOptionEnabled        = $CurrentSettings.securityQuestionsOptionEnabled #: False
        mobileAppNotificationEnabled          = $CurrentSettings.mobileAppNotificationEnabled #: False
        mobileAppCodeEnabled                  = $CurrentSettings.mobileAppCodeEnabled #: True
        numberOfQuestionsToRegister           = $CurrentSettings.numberOfQuestionsToRegister #: 5
        numberOfQuestionsToReset              = $CurrentSettings.numberOfQuestionsToReset #: 3
        registrationRequiredOnSignIn          = $CurrentSettings.registrationRequiredOnSignIn #: True
        registrationReconfirmIntevalInDays    = $CurrentSettings.registrationReconfirmIntevalInDays #: 180
        skipRegistrationAllowed               = $CurrentSettings.skipRegistrationAllowed #: True
        skipRegistrationMaxAllowedDays        = $CurrentSettings.skipRegistrationMaxAllowedDays #: 7
        customizeHelpdeskLink                 = $CurrentSettings.customizeHelpdeskLink #: False
        customHelpdeskEmailOrUrl              = $CurrentSettings.customHelpdeskEmailOrUrl #:
        notifyUsersOnPasswordReset            = $CurrentSettings.notifyUsersOnPasswordReset #: True
        notifyOnAdminPasswordReset            = $CurrentSettings.notifyOnAdminPasswordReset #: True
        passwordResetEnabledGroupIds          = $CurrentSettings.passwordResetEnabledGroupIds #: {b6cdb9c3-d660-4558-bcfd-82c14a986b56}
        passwordResetEnabledGroupName         = $CurrentSettings.passwordResetEnabledGroupName #:
        securityQuestions                     = $CurrentSettings.securityQuestions #: {}
        registrationConditionalAccessPolicies = $CurrentSettings.registrationConditionalAccessPolicies #: {}
        emailOptionAllowed                    = $CurrentSettings.emailOptionAllowed #: True
        mobilePhoneOptionAllowed              = $CurrentSettings.mobilePhoneOptionAllowed #: True
        officePhoneOptionAllowed              = $CurrentSettings.officePhoneOptionAllowed #: True
        securityQuestionsOptionAllowed        = $CurrentSettings.securityQuestionsOptionAllowed #: True
        mobileAppNotificationOptionAllowed    = $CurrentSettings.mobileAppNotificationOptionAllowed #: True
        mobileAppCodeOptionAllowed            = $CurrentSettings.mobileAppCodeOptionAllowed #: True
    }

    if ($null -ne $EnablementType) {
        $Body.enablementType = $EnablementType
    }
    if ($null -ne $NumberOfAuthenticationMethodsRequired) {
        $Body.numberOfAuthenticationMethodsRequired = $NumberOfAuthenticationMethodsRequired
    }
    if ($null -ne $EmailOptionEnabled) {
        $Body.emailOptionEnabled = $EmailOptionEnabled
    }
    if ($null -ne $MobilePhoneOptionEnabled) {
        $Body.mobilePhoneOptionEnabled = $MobilePhoneOptionEnabled
    }
    if ($null -ne $OfficePhoneOptionEnabled) {
        $Body.officePhoneOptionEnabled = $OfficePhoneOptionEnabled
    }
    if ($null -ne $SecurityQuestionsOptionEnabled) {
        $Body.securityQuestionsOptionEnabled = $SecurityQuestionsOptionEnabled
    }
    if ($null -ne $MobileAppNotificationEnabled) {
        $Body.mobileAppNotificationEnabled = $MobileAppNotificationEnabled
    }
    if ($null -ne $MobileAppCodeEnabled) {
        $Body.mobileAppCodeEnabled = $MobileAppCodeEnabled
    }
    if ($null -ne $NumberOfQuestionsToRegister) {
        $Body.numberOfQuestionsToRegister = $NumberOfQuestionsToRegister
    }
    if ($null -ne $NumberOfQuestionsToReset) {
        $Body.numberOfQuestionsToReset = $NumberOfQuestionsToReset
    }
    if ($null -ne $RegistrationRequiredOnSignIn) {
        $Body.registrationRequiredOnSignIn = $RegistrationRequiredOnSignIn
    }
    if ($null -ne $RegistrationReconfirmIntevalInDays) {
        $Body.registrationReconfirmIntevalInDays = $RegistrationReconfirmIntevalInDays
    }
    if ($null -ne $SkipRegistrationAllowed) {
        $Body.skipRegistrationAllowed = $SkipRegistrationAllowed
    }
    if ($null -ne $SkipRegistrationMaxAllowedDays) {
        $Body.skipRegistrationMaxAllowedDays = $SkipRegistrationMaxAllowedDays
    }
    if ($CustomizeHelpdeskLink) {
        $Body.customizeHelpdeskLink = $CustomizeHelpdeskLink
    }
    if ($null -ne $CustomHelpdeskEmailOrUrl) {
        $Body.customHelpdeskEmailOrUrl = $CustomHelpdeskEmailOrUrl
    }
    if ($null -ne $NotifyUsersOnPasswordReset) {
        $Body.notifyUsersOnPasswordReset = $NotifyUsersOnPasswordReset
    }
    if ($null -ne $NotifyOnAdminPasswordReset) {
        $Body.notifyOnAdminPasswordReset = $NotifyOnAdminPasswordReset
    }
    if ($PasswordResetEnabledGroupName) {
        # We should find an easy way to find ID of a group and set it here
        # Not implemented yet
        $Body.passwordResetEnabledGroupIds = @(
            # Query for group id from group name $PasswordResetEnabledGroupName
        )
        throw 'PasswordResetEnabledGroupName is not implemented yet'
    } elseif ($PasswordResetEnabledGroupIds) {
        $Body.passwordResetEnabledGroupIds = @(
            $PasswordResetEnabledGroupIds
        )

        # This seems like an empty value - always
        $Body.passwordResetEnabledGroupName = ''
    }
    if ($null -ne $SecurityQuestions) {
        $Body.securityQuestions = $SecurityQuestions
    }
    if ($null -ne $RegistrationConditionalAccessPolicies) {
        $Body.registrationConditionalAccessPolicies = $RegistrationConditionalAccessPolicies
    }
    if ($null -ne $EmailOptionAllowed) {
        $Body.emailOptionAllowed = $EmailOptionAllowed
    }
    if ($null -ne $MobilePhoneOptionAllowed) {
        $Body.mobilePhoneOptionAllowed = $MobilePhoneOptionAllowed
    }
    if ($null -ne $OfficePhoneOptionAllowed) {
        $Body.officePhoneOptionAllowed = $OfficePhoneOptionAllowed
    }
    if ($null -ne $SecurityQuestionsOptionAllowed) {
        $Body.securityQuestionsOptionAllowed = $SecurityQuestionsOptionAllowed
    }
    if ($null -ne $mobileAppNotificationOptionAllowed) {
        $Body.mobileAppNotificationOptionAllowed = $mobileAppNotificationOptionAllowed
    }
    if ($null -ne $mobileAppCodeOptionAllowed) {
        $Body.mobileAppCodeOptionAllowed = $mobileAppCodeOptionAllowed
    }

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body
    #$Output
}

<#
PUT https://main.iam.ad.ext.azure.com/api/PasswordReset/PasswordResetPolicies HTTP/1.1
Host: main.iam.ad.ext.azure.com
Connection: keep-alive
Content-Length: 949
x-ms-client-session-id: 1689d960822a4322958876376066cc18
Accept-Language: en
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiI3NDY1ODEzNi0xNGVjLTQ2MzAtYWQ5Yi0yNmUxNjBmZjBmYzYiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9jZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEvIiwiaWF0IjoxNjI5NjE4MjI5LCJuYmYiOjE2Mjk2MTgyMjksImV4cCI6MTYyOTYyMjEyOSwiYWNyIjoiMSIsImFpbyI6IkFWUUFxLzhUQUFBQU5QWXA4cm5DUG5wcGRmdHh6SmxWNDBMVEo3UHJabVlnNEh6M2w4SDlLclR2WVpzUVhlTVlrOWJSS1pWQ0k1VDk2bnhLajdwdW55cFJVQjNLQ2h1cm9mZEpsYXZPZnVKT3NSWkU2TXRlZVZJPSIsImFtciI6WyJyc2EiLCJtZmEiXSwiYXBwaWQiOiJjNDRiNDA4My0zYmIwLTQ5YzEtYjQ3ZC05NzRlNTNjYmRmM2MiLCJhcHBpZGFjciI6IjIiLCJkZXZpY2VpZCI6IjNhZTIyNzI2LWRmZDktNGFkNy1hODY1LWFhMmI1MWM2ZTBmZiIsImZhbWlseV9uYW1lIjoiS8WCeXMiLCJnaXZlbl9uYW1lIjoiUHJ6ZW15c8WCYXciLCJpcGFkZHIiOiI4OS43Ny4xMDIuMTciLCJuYW1lIjoiUHJ6ZW15c8WCYXcgS8WCeXMiLCJvaWQiOiJlNmE4ZjFjZi0wODc0LTQzMjMtYTEyZi0yYmY1MWJiNmRmZGQiLCJvbnByZW1fc2lkIjoiUy0xLTUtMjEtODUzNjE1OTg1LTI4NzA0NDUzMzktMzE2MzU5ODY1OS0xMTA1IiwicHVpZCI6IjEwMDMwMDAwOTQ0REI4NEQiLCJyaCI6IjAuQVM4QTluR3p6a1dIZGtpZ1FHbnkwUXFkR29OQVM4U3dPOEZKdEgyWFRsUEwzend2QUM4LiIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInN1YiI6ImVvU3lzNXlDNmJvWmQ5a21YRXVNSWl5YUxhX1g1VTdmSWZJck1DV0hORjQiLCJ0ZW5hbnRfcmVnaW9uX3Njb3BlIjoiRVUiLCJ0aWQiOiJjZWIzNzFmNi04NzQ1LTQ4NzYtYTA0MC02OWYyZDEwYTlkMWEiLCJ1bmlxdWVfbmFtZSI6InByemVteXNsYXcua2x5c0Bldm90ZWMucGwiLCJ1cG4iOiJwcnplbXlzbGF3LmtseXNAZXZvdGVjLnBsIiwidXRpIjoiUUt0MW1LclhUMC14SFN4N09La2ZBQSIsInZlciI6IjEuMCIsIndpZHMiOlsiNjJlOTAzOTQtNjlmNS00MjM3LTkxOTAtMDEyMTc3MTQ1ZTEwIiwiYjc5ZmJmNGQtM2VmOS00Njg5LTgxNDMtNzZiMTk0ZTg1NTA5Il0sInhtc190Y2R0IjoxNDQ0ODQ1NTQ0fQ.IM4HTn1XeyjxT_jaY79L6r5YZekPr1PN8r0VDbQz0-iUfOd_jTIj-gc2Tpk_ix5auf_MSex44JWtgdoVz6n3vNhc8ZSBS2PrSePr9I30r1S5EolAnVCgYUoGL1nhaE0XhaIY8XI1AgQywp98f_MuZebbgBPT5k1pyrht6n-yjWFGJIJNCt9pq4YI5klWHBuOCe9k3OBVnoi4NZZ3cbNuH6JaPl2dvAj2J3gJB_xOEkfpYOOTdlL_jB9Cko5UmXDkZMrCB31FDkkW-hlGAE3bMR9DFkbGWLgvRpGeRMR2P3anT9n27h3RjIL20vxq5xdQwZNDTMQrB7yadblfYeDS4w
x-ms-effective-locale: en.en-us
Content-Type: application/json
Accept: */*
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36 Edg/92.0.902.78
x-ms-client-request-id: 72138869-69fc-4c61-ad82-98ee046970a8
Origin: https://portal.azure.com
Sec-Fetch-Site: same-site
Sec-Fetch-Mode: cors
Sec-Fetch-Dest: empty
Accept-Encoding: gzip, deflate, br

{
    "objectId":"default","enablementType":2,"numberOfAuthenticationMethodsRequired":1,
"emailOptionEnabled":true,"mobilePhoneOptionEnabled":true,"officePhoneOptionEnabled":false,
"securityQuestionsOptionEnabled":false,"mobileAppNotificationEnabled":false,"mobileAppCodeEnabled":true,
"numberOfQuestionsToRegister":5,"numberOfQuestionsToReset":3,"registrationRequiredOnSignIn":true,
"registrationReconfirmIntevalInDays":180,"skipRegistrationAllowed":true,"skipRegistrationMaxAllowedDays":7,
"customizeHelpdeskLink":false,"customHelpdeskEmailOrUrl":"","notifyUsersOnPasswordReset":true,"notifyOnAdminPasswordReset":true,
"passwordResetEnabledGroupIds":[],"passwordResetEnabledGroupName":"","securityQuestions":[],
"registrationConditionalAccessPolicies":[],"emailOptionAllowed":true,"mobilePhoneOptionAllowed":true,
"officePhoneOptionAllowed":true,"securityQuestionsOptionAllowed":true,"mobileAppNotificationOptionAllowed":true,
"mobileAppCodeOptionAllowed":true
}
#>