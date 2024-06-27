function Set-O365OrgModernAuthentication {
    <#
    .SYNOPSIS
    Configures Modern Authentication settings for an Office 365 organization.

    .DESCRIPTION
    This function allows you to configure the Modern Authentication settings for your Office 365 organization. 
    It sends a POST request to the Office 365 admin API with the specified settings.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER EnableModernAuth
    Specifies whether Modern Authentication should be enabled.

    .PARAMETER SecureDefaults
    Specifies whether Secure Defaults should be enabled.

    .PARAMETER DisableModernAuth
    Specifies whether Modern Authentication should be disabled.

    .PARAMETER AllowBasicAuthActiveSync
    Specifies whether Basic Authentication for ActiveSync should be allowed.

    .PARAMETER AllowBasicAuthImap
    Specifies whether Basic Authentication for IMAP should be allowed.

    .PARAMETER AllowBasicAuthPop
    Specifies whether Basic Authentication for POP should be allowed.

    .PARAMETER AllowBasicAuthWebServices
    Specifies whether Basic Authentication for Web Services should be allowed.

    .PARAMETER AllowBasicAuthPowershell
    Specifies whether Basic Authentication for PowerShell should be allowed.

    .PARAMETER AllowBasicAuthAutodiscover
    Specifies whether Basic Authentication for Autodiscover should be allowed.

    .PARAMETER AllowBasicAuthMapi
    Specifies whether Basic Authentication for MAPI should be allowed.

    .PARAMETER AllowBasicAuthOfflineAddressBook
    Specifies whether Basic Authentication for Offline Address Book should be allowed.

    .PARAMETER AllowBasicAuthRpc
    Specifies whether Basic Authentication for RPC should be allowed.

    .PARAMETER AllowBasicAuthSmtp
    Specifies whether Basic Authentication for SMTP should be allowed.

    .PARAMETER AllowOutlookClient
    Specifies whether Basic Authentication for Outlook Client should be allowed.

    .EXAMPLE
    Set-O365OrgModernAuthentication -AllowBasicAuthImap $true -AllowBasicAuthPop $true -WhatIf

    This example enables Basic Authentication for IMAP and POP, and uses the WhatIf parameter to show what would happen if the command runs.

    .EXAMPLE
    Set-O365OrgModernAuthentication -AllowBasicAuthImap $false -AllowBasicAuthPop $false -Verbose -WhatIf

    This example disables Basic Authentication for IMAP and POP, and uses the Verbose and WhatIf parameters to show detailed information about what would happen if the command runs.

    .NOTES
    https://admin.microsoft.com/#/Settings/Services/:/Settings/L1/ModernAuthentication
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $EnableModernAuth, #: True
        [nullable[bool]] $SecureDefaults, #: False
        [nullable[bool]] $DisableModernAuth, #: False
        [nullable[bool]] $AllowBasicAuthActiveSync, #: True
        [nullable[bool]] $AllowBasicAuthImap, #: True
        [nullable[bool]] $AllowBasicAuthPop, #: True
        [nullable[bool]] $AllowBasicAuthWebServices, #: True
        [nullable[bool]] $AllowBasicAuthPowershell, #: True
        [nullable[bool]] $AllowBasicAuthAutodiscover, #: True
        [nullable[bool]] $AllowBasicAuthMapi, #: True
        [nullable[bool]] $AllowBasicAuthOfflineAddressBook , #: True
        [nullable[bool]] $AllowBasicAuthRpc, #: True
        [nullable[bool]] $AllowBasicAuthSmtp, #: True
        [nullable[bool]] $AllowOutlookClient                #:
    )
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/modernAuth"
    $CurrentSettings = Get-O365OrgModernAuthentication -Headers $Headers
    if (-not $CurrentSettings) {
        Write-Warning -Message "Set-O365ModernAuthentication - Couldn't gather current settings. Skipping setting anything."
        return
    }
    $Body = [ordered] @{
        EnableModernAuth                 = $CurrentSettings.EnableModernAuth                 #: True
        SecureDefaults                   = $CurrentSettings.SecureDefaults                   #: False
        DisableModernAuth                = $CurrentSettings.DisableModernAuth                #: False
        AllowBasicAuthActiveSync         = $CurrentSettings.AllowBasicAuthActiveSync         #: True
        AllowBasicAuthImap               = $CurrentSettings.AllowBasicAuthImap               #: False
        AllowBasicAuthPop                = $CurrentSettings.AllowBasicAuthPop                #: False
        AllowBasicAuthWebServices        = $CurrentSettings.AllowBasicAuthWebServices        #: True
        AllowBasicAuthPowershell         = $CurrentSettings.AllowBasicAuthPowershell         #: True
        AllowBasicAuthAutodiscover       = $CurrentSettings.AllowBasicAuthAutodiscover       #: True
        AllowBasicAuthMapi               = $CurrentSettings.AllowBasicAuthMapi               #: True
        AllowBasicAuthOfflineAddressBook = $CurrentSettings.AllowBasicAuthOfflineAddressBook #: True
        AllowBasicAuthRpc                = $CurrentSettings.AllowBasicAuthRpc                #: True
        AllowBasicAuthSmtp               = $CurrentSettings.AllowBasicAuthSmtp               #: True
        AllowOutlookClient               = $CurrentSettings.AllowOutlookClient               #: True
    }
    if ($null -ne $SecureDefaults) {
        $Body.SecureDefaults = $SecureDefaults
    }
    if ($null -ne $EnableModernAuth) {
        $Body.EnableModernAuth = $EnableModernAuth
    }
    if ($null -ne $DisableModernAuth) {
        $Body.DisableModernAuth = $DisableModernAuth
    }
    if ($null -ne $AllowBasicAuthActiveSync) {
        $Body.AllowBasicAuthActiveSync = $AllowBasicAuthActiveSync
    }
    if ($null -ne $AllowBasicAuthImap) {
        $Body.AllowBasicAuthImap = $AllowBasicAuthImap
    }
    if ($null -ne $AllowBasicAuthPop) {
        $Body.AllowBasicAuthPop = $AllowBasicAuthPop
    }
    if ($null -ne $AllowBasicAuthWebServices) {
        $Body.AllowBasicAuthWebServices = $AllowBasicAuthWebServices
    }
    if ($null -ne $AllowBasicAuthPowershell) {
        $Body.AllowBasicAuthPowershell = $AllowBasicAuthPowershell
    }
    if ($null -ne $AllowBasicAuthAutodiscover) {
        $Body.AllowBasicAuthAutodiscover = $AllowBasicAuthAutodiscover
    }
    if ($null -ne $AllowBasicAuthMapi) {
        $Body.AllowBasicAuthMapi = $AllowBasicAuthMapi
    }
    if ($null -ne $AllowBasicAuthOfflineAddressBook) {
        $Body.AllowBasicAuthOfflineAddressBook = $AllowBasicAuthOfflineAddressBook
    }
    if ($null -ne $AllowBasicAuthRpc) {
        $Body.AllowBasicAuthRpc = $AllowBasicAuthRpc
    }
    if ($null -ne $AllowBasicAuthSmtp) {
        $Body.AllowBasicAuthSmtp = $AllowBasicAuthSmtp
    }
    if ($null -ne $AllowOutlookClient) {
        $Body.AllowOutlookClient = $AllowOutlookClient
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    $Output
}
