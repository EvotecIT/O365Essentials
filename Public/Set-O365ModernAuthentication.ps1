function Set-O365ModernAuthentication {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Headers
    Parameter description

    .PARAMETER EnableModernAuth
    Parameter description

    .PARAMETER SecureDefaults
    Parameter description

    .PARAMETER DisableModernAuth
    Parameter description

    .PARAMETER AllowBasicAuthActiveSync
    Parameter description

    .PARAMETER AllowBasicAuthImap
    Parameter description

    .PARAMETER AllowBasicAuthPop
    Parameter description

    .PARAMETER AllowBasicAuthWebServices
    Parameter description

    .PARAMETER AllowBasicAuthPowershell
    Parameter description

    .PARAMETER AllowBasicAuthAutodiscover
    Parameter description

    .PARAMETER AllowBasicAuthMapi
    Parameter description

    .PARAMETER AllowBasicAuthOfflineAddressBook
    Parameter description

    .PARAMETER AllowBasicAuthRpc
    Parameter description

    .PARAMETER AllowBasicAuthSmtp
    Parameter description

    .PARAMETER AllowOutlookClient
    Parameter description

    .EXAMPLE
    Set-O365ModernAuthentication -AllowBasicAuthImap $true -AllowBasicAuthPop $true -WhatIf

    .EXAMPLE
    Set-O365ModernAuthentication -AllowBasicAuthImap $false -AllowBasicAuthPop $false -Verbose -WhatIf

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
    $Uri = "https://admin.microsoft.com/admin/api/services/apps/modernAuth"
    $CurrentSettings = Get-O365ModernAuthentication -Headers $Headers
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