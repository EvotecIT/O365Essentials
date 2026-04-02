function Connect-O365Admin {
    <#
    .SYNOPSIS
    Connects to Microsoft 365 admin workloads used by O365Essentials.

    .DESCRIPTION
    Creates or refreshes the shared O365Essentials authorization cache used by the
    module's Graph, ARM, Teams, Substrate, and admin center readers.

    For normal users this remains the only public connection command. Host apps can
    transparently attach an existing admin.cloud.microsoft portal session by supplying
    hidden portal artifacts through the hidden PortalAttach* parameters or the
    process-scoped O365ESSENTIALS_PORTAL_* environment variables consumed by
    Get-O365PortalAttachmentContext.

    When portal attachment state is present, Connect-O365Admin folds that browser-backed
    session into the cached authorization object so portal-sensitive routes can later
    replay through Invoke-O365Admin without changing the user-facing workflow.
    #>
    [cmdletbinding(DefaultParameterSetName = 'Credential')]
    param(
        [parameter(ParameterSetName = 'Credential')][PSCredential] $Credential,
        [parameter(ParameterSetName = 'Headers', DontShow)][alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(ParameterSetName = 'App')][string] $ClientId,
        [parameter(ParameterSetName = 'App')][string] $ClientSecret,
        [parameter(ParameterSetName = 'App')] $Certificate,
        [parameter(ParameterSetName = 'App')][securestring] $CertificatePassword,
        [int] $ExpiresIn = 3600,
        [int] $ExpiresTimeout = 30,
        [switch] $ForceRefresh,
        [switch] $Device,
        # Tenant ID; defaults to 'organizations' and is replaced with the actual tenant after sign-in
        [alias('TenantID')][string] $Tenant,
        [string] $DomainName,
        [string] $Subscription,
        # Hidden portal attachment inputs are intended for host/app integrations only.
        # End users should still call Connect-O365Admin the same way as before.
        [Parameter(DontShow)][Microsoft.PowerShell.Commands.WebRequestSession] $PortalAttachWebSession,
        [Parameter(DontShow)][string] $PortalAttachRootAuthToken,
        [Parameter(DontShow)][string] $PortalAttachSPAAuthCookie,
        [Parameter(DontShow)][string] $PortalAttachOIDCAuthCookie,
        [Parameter(DontShow)][string] $PortalAttachAjaxSessionKey,
        [Parameter(DontShow)][string] $PortalAttachSessionId,
        [Parameter(DontShow)][string] $PortalAttachTenantId,
        [Parameter(DontShow)][string] $PortalAttachRouteKey,
        [Parameter(DontShow)][string] $PortalAttachUserName,
        [Parameter(DontShow)][System.Collections.IDictionary] $PortalAttachCookieMap,
        [Parameter(DontShow)][switch] $SkipPortalBootstrap
    )

    $HasPortalAttachInput = $PSBoundParameters.ContainsKey('PortalAttachWebSession') -or
        $PSBoundParameters.ContainsKey('PortalAttachRootAuthToken') -or
        $PSBoundParameters.ContainsKey('PortalAttachSPAAuthCookie') -or
        $PSBoundParameters.ContainsKey('PortalAttachOIDCAuthCookie') -or
        $PSBoundParameters.ContainsKey('PortalAttachAjaxSessionKey') -or
        $PSBoundParameters.ContainsKey('PortalAttachSessionId') -or
        $PSBoundParameters.ContainsKey('PortalAttachTenantId') -or
        $PSBoundParameters.ContainsKey('PortalAttachRouteKey') -or
        $PSBoundParameters.ContainsKey('PortalAttachUserName') -or
        $PSBoundParameters.ContainsKey('PortalAttachCookieMap')
    $UsePortalAttachWebSession = $PSBoundParameters.ContainsKey('PortalAttachWebSession')
    $UsePortalAttachCookies = $PSBoundParameters.ContainsKey('PortalAttachRootAuthToken')

    if (-not $HasPortalAttachInput) {
        $PortalAttachmentContext = Get-O365PortalAttachmentContext
        if ($PortalAttachmentContext) {
            $PortalAttachRootAuthToken = $PortalAttachmentContext.RootAuthToken
            $PortalAttachSPAAuthCookie = $PortalAttachmentContext.SPAAuthCookie
            $PortalAttachOIDCAuthCookie = $PortalAttachmentContext.OIDCAuthCookie
            $PortalAttachAjaxSessionKey = $PortalAttachmentContext.AjaxSessionKey
            $PortalAttachSessionId = $PortalAttachmentContext.SessionId
            $PortalAttachTenantId = $PortalAttachmentContext.TenantId
            $PortalAttachRouteKey = $PortalAttachmentContext.PortalRouteKey
            $PortalAttachUserName = $PortalAttachmentContext.Username
            $PortalAttachCookieMap = $PortalAttachmentContext.CookieMap
            if ($PortalAttachmentContext.SkipBootstrap) {
                $SkipPortalBootstrap = $true
            }
            $HasPortalAttachInput = $true
            $UsePortalAttachCookies = $true
        }
    }

    $RefreshToken = $null
    $PortalWebSession = $null
    $AjaxSessionKey = $null
    $PortalRouteKey = $null
    $PortalUserId = $null
    $PortalTenantId = $null
    $HeadersPortal = $null
    if ($Headers) {
        if ($Headers.ExpiresOnUTC -gt [datetime]::UtcNow -and -not $ForceRefresh -and -not $HasPortalAttachInput) {
            Write-Verbose -Message "Connect-O365Admin - Using cache for connection $($Headers.UserName)"
            return $Headers
        } else {
            $Credential = $Headers.Credential
            $ClientId = $Headers.ClientId
            $ClientSecret = $Headers.ClientSecret
            $Certificate = $Headers.Certificate
            $CertificatePassword = $Headers.CertificatePassword
            $Tenant = $Headers.Tenant
            $Subscription = $Headers.Subscription
            $RefreshToken = $Headers.RefreshToken
            if ($Headers.Contains('PortalWebSession')) { $PortalWebSession = $Headers.PortalWebSession }
            if ($Headers.Contains('AjaxSessionKey')) { $AjaxSessionKey = $Headers.AjaxSessionKey }
            if ($Headers.Contains('PortalRouteKey')) { $PortalRouteKey = $Headers.PortalRouteKey }
            if ($Headers.Contains('PortalUserId')) { $PortalUserId = $Headers.PortalUserId }
            if ($Headers.Contains('PortalTenantId')) { $PortalTenantId = $Headers.PortalTenantId }
            if ($Headers.Contains('HeadersPortal')) { $HeadersPortal = $Headers.HeadersPortal }
        }
    } elseif ($Script:AuthorizationO365Cache) {
        if ($Script:AuthorizationO365Cache.ExpiresOnUTC -gt [datetime]::UtcNow -and -not $ForceRefresh -and -not $HasPortalAttachInput) {
            Write-Verbose -Message "Connect-O365Admin - Using cache for connection $($Script:AuthorizationO365Cache.UserName)"
            return $Script:AuthorizationO365Cache
        } else {
            $Credential = $Script:AuthorizationO365Cache.Credential
            $ClientId = $Script:AuthorizationO365Cache.ClientId
            $ClientSecret = $Script:AuthorizationO365Cache.ClientSecret
            $Certificate = $Script:AuthorizationO365Cache.Certificate
            $CertificatePassword = $Script:AuthorizationO365Cache.CertificatePassword
            $Tenant = $Script:AuthorizationO365Cache.Tenant
            $Subscription = $Script:AuthorizationO365Cache.Subscription
            $RefreshToken = $Script:AuthorizationO365Cache.RefreshToken
            if ($Script:AuthorizationO365Cache.Contains('PortalWebSession')) { $PortalWebSession = $Script:AuthorizationO365Cache.PortalWebSession }
            if ($Script:AuthorizationO365Cache.Contains('AjaxSessionKey')) { $AjaxSessionKey = $Script:AuthorizationO365Cache.AjaxSessionKey }
            if ($Script:AuthorizationO365Cache.Contains('PortalRouteKey')) { $PortalRouteKey = $Script:AuthorizationO365Cache.PortalRouteKey }
            if ($Script:AuthorizationO365Cache.Contains('PortalUserId')) { $PortalUserId = $Script:AuthorizationO365Cache.PortalUserId }
            if ($Script:AuthorizationO365Cache.Contains('PortalTenantId')) { $PortalTenantId = $Script:AuthorizationO365Cache.PortalTenantId }
            if ($Script:AuthorizationO365Cache.Contains('HeadersPortal')) { $HeadersPortal = $Script:AuthorizationO365Cache.HeadersPortal }
        }
    }

    if ($HasPortalAttachInput -and -not $ForceRefresh) {
        $CachedHeaders = if ($Headers) {
            $Headers
        } elseif ($Script:AuthorizationO365Cache) {
            $Script:AuthorizationO365Cache
        } else {
            $null
        }

        if ($CachedHeaders -and $CachedHeaders.ExpiresOnUTC -gt [datetime]::UtcNow) {
            $PortalParams = @{
                Headers = $CachedHeaders
            }
            if ($UsePortalAttachWebSession) {
                $PortalParams.WebSession = $PortalAttachWebSession
            } elseif ($UsePortalAttachCookies) {
                $PortalParams.RootAuthToken = $PortalAttachRootAuthToken
                if (-not [string]::IsNullOrWhiteSpace($PortalAttachSPAAuthCookie)) {
                    $PortalParams.SPAAuthCookie = $PortalAttachSPAAuthCookie
                }
                if (-not [string]::IsNullOrWhiteSpace($PortalAttachOIDCAuthCookie)) {
                    $PortalParams.OIDCAuthCookie = $PortalAttachOIDCAuthCookie
                }
                if (-not [string]::IsNullOrWhiteSpace($PortalAttachAjaxSessionKey)) {
                    $PortalParams.AjaxSessionKey = $PortalAttachAjaxSessionKey
                }
                if (-not [string]::IsNullOrWhiteSpace($PortalAttachSessionId)) {
                    $PortalParams.SessionId = $PortalAttachSessionId
                }
                if (-not [string]::IsNullOrWhiteSpace($PortalAttachTenantId)) {
                    $PortalParams.TenantId = $PortalAttachTenantId
                }
                if (-not [string]::IsNullOrWhiteSpace($PortalAttachRouteKey)) {
                    $PortalParams.PortalRouteKey = $PortalAttachRouteKey
                }
                if (-not [string]::IsNullOrWhiteSpace($PortalAttachUserName)) {
                    $PortalParams.Username = $PortalAttachUserName
                }
                if ($PortalAttachCookieMap) {
                    $PortalParams.AdditionalCookies = $PortalAttachCookieMap
                }
            }
            if ($SkipPortalBootstrap) {
                $PortalParams.SkipBootstrap = $true
            }

            return Set-O365PortalSession @PortalParams
        }
    }

    if ($DomainName) {
        Write-Verbose -Message "Connect-O365Admin - Querying tenant to get domain name"
        $Tenant = Get-O365TenantID -DomainName $DomainName
    }

    $Tenant = if ($Tenant) { $Tenant } else { 'organizations' }
    $ScopesO365 = 'https://admin.microsoft.com/.default offline_access'
    # Admin and directory portal routes can require the Microsoft 365/Azure portal audience
    $ResourceAzure = '74658136-14ec-4630-ad9b-26e160ff0fc6'
    # Use the management.azure.com resource for ARM token acquisition
    $ScopesARM = 'https://management.azure.com/.default offline_access'
    $ScopesGraph = 'https://graph.microsoft.com/.default offline_access'
    # Teams admin APIs on teams.microsoft.com expect a token for api.spaces.skype.com
    $ScopesTeams = 'https://api.spaces.skype.com/.default offline_access'
    # Substrate Admin App Catalog (used by Teams admin UI to reflect app availability) — use v1 resource GUID
    $ResourceSubstrate = '08ff1ce2-4973-4b08-86a3-ebed13badc7f'

    try {
        Write-Verbose -Message "Connect-O365Admin - Acquiring token for Graph"
        if ($PSCmdlet.ParameterSetName -eq 'App') {
            $tokenGraph = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesGraph -ClientId $ClientId -ClientSecret $ClientSecret -Certificate $Certificate -CertificatePassword $CertificatePassword
        } elseif ($RefreshToken -and -not $Credential -and -not $Device) {
            $tokenGraph = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesGraph -RefreshToken $RefreshToken
        } else {
            $tokenGraph = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesGraph -Credential $Credential -Device:$Device
        }
    } catch {
        $CanRetryWithDevice = -not $Device -and $PSCmdlet.ParameterSetName -ne 'App' -and $_.Exception.Message -match 'Failed to listen on prefix|localhost:8400'
        if ($CanRetryWithDevice) {
            Write-Verbose -Message "Connect-O365Admin - Interactive listener failed. Falling back to device code for Graph."
            try {
                $tokenGraph = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesGraph -Credential $Credential -Device
            } catch {
                Write-Warning -Message "Connect-O365Admin - Authentication failure for Graph after device fallback. Error: $($_.Exception.Message)"
                return
            }
        } else {
            Write-Warning -Message "Connect-O365Admin - Authentication failure for Graph. Error: $($_.Exception.Message)"
            return
        }
    }

    # Read tenant information from the token so subsequent requests use the correct tenant
    $jwtTenant = if ($tokenGraph.id_token) { $tokenGraph.id_token } else { $tokenGraph.access_token }
    $tenantInfo = ConvertFrom-JSONWebToken -Token $jwtTenant
    if (-not $PSBoundParameters.ContainsKey('Tenant') -or $Tenant -eq 'organizations') {
        $Tenant = $tenantInfo.tid
    }
    $refresh = $tokenGraph.refresh_token
    $tokenO365 = $null
    $tokenAzure = $null
    try {
        Write-Verbose -Message "Connect-O365Admin - Acquiring token for admin.microsoft.com"
        if ($PSCmdlet.ParameterSetName -eq 'App') {
            $tokenO365 = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesO365 -ClientId $ClientId -ClientSecret $ClientSecret -Certificate $Certificate -CertificatePassword $CertificatePassword
        } else {
            $tokenO365 = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesO365 -RefreshToken $refresh
        }
    } catch {
        Write-Verbose -Message "Connect-O365Admin - admin.microsoft.com scope token failed. Falling back to portal resource audience. Error: $($_.Exception.Message)"
        try {
            if ($PSCmdlet.ParameterSetName -eq 'App') {
                $tokenO365 = Get-O365OAuthToken -Tenant $Tenant -Resource $ResourceAzure -ClientId $ClientId -ClientSecret $ClientSecret -Certificate $Certificate -CertificatePassword $CertificatePassword
            } else {
                $tokenO365 = Get-O365OAuthToken -Tenant $Tenant -Resource $ResourceAzure -RefreshToken $refresh
            }
            $tokenAzure = $tokenO365
            Write-Verbose -Message "Connect-O365Admin - Using portal resource token for admin.microsoft.com routes"
        } catch {
            Write-Warning -Message "Connect-O365Admin - Authentication failure for admin.microsoft.com and portal resource fallback. Error: $($_.Exception.Message)"
            return
        }
    }
    try {
        Write-Verbose -Message "Connect-O365Admin - Acquiring token for Teams (api.spaces.skype.com)"
        if ($PSCmdlet.ParameterSetName -eq 'App') {
            $tokenTeams = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesTeams -ClientId $ClientId -ClientSecret $ClientSecret -Certificate $Certificate -CertificatePassword $CertificatePassword
        } else {
            $tokenTeams = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesTeams -RefreshToken $refresh
        }
    } catch {
        Write-Warning -Message "Connect-O365Admin - Authentication failure for Teams (api.spaces.skype.com). Error: $($_.Exception.Message)"
        $tokenTeams = $null
    }
    if (-not $tokenAzure) {
        try {
            Write-Verbose -Message "Connect-O365Admin - Acquiring token for Azure"
            if ($PSCmdlet.ParameterSetName -eq 'App') {
                $tokenAzure = Get-O365OAuthToken -Tenant $Tenant -Resource $ResourceAzure -ClientId $ClientId -ClientSecret $ClientSecret -Certificate $Certificate -CertificatePassword $CertificatePassword
            } else {
                $tokenAzure = Get-O365OAuthToken -Tenant $Tenant -Resource $ResourceAzure -RefreshToken $refresh
            }
        } catch {
            Write-Warning -Message "Connect-O365Admin - Authentication failure for Azure. Error: $($_.Exception.Message)"
            $tokenAzure = $null
        }
    }
    try {
        Write-Verbose -Message "Connect-O365Admin - Acquiring token for Azure management"
        if ($PSCmdlet.ParameterSetName -eq 'App') {
            $tokenARM = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesARM -ClientId $ClientId -ClientSecret $ClientSecret -Certificate $Certificate -CertificatePassword $CertificatePassword
        } else {
            $tokenARM = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesARM -RefreshToken $refresh
        }
    } catch {
        Write-Warning -Message "Connect-O365Admin - Authentication failure for Azure management. Error: $($_.Exception.Message)"
        $tokenARM = $null
    }

    # Prefer a persisted Substrate refresh token/client if present
    $tokenSubstrate = $null
    try {
        $cfg = Get-O365EssentialsConfig
        if ($cfg.Substrate -and $cfg.Substrate.ClientId -and $cfg.Substrate.RefreshToken) {
            $rt = Unprotect-O365Secret -Protected $cfg.Substrate.RefreshToken
            Write-Verbose -Message "Connect-O365Admin - Using persisted Substrate client to acquire token"
            $tokenSubstrate = Get-O365OAuthToken -Tenant $Tenant -Scope 'https://substrate.office.com/.default offline_access' -ClientId $cfg.Substrate.ClientId -RefreshToken $rt
        }
    } catch { $tokenSubstrate = $null }

    if (-not $tokenSubstrate) {
        # Fallback: try multiple known audiences with the current client (may fail for first-party APIs)
        $substrateAttempts = @(
            @{ type = 'resource'; value = 'https://substrate.office.com' },
            @{ type = 'scope';    value = 'https://substrate.office.com/.default offline_access' },
            @{ type = 'resource'; value = $ResourceSubstrate },
            @{ type = 'scope';    value = "api://$ResourceSubstrate/.default offline_access" }
        )
        foreach ($attempt in $substrateAttempts) {
            if ($tokenSubstrate) { break }
            try {
                Write-Verbose -Message "Connect-O365Admin - Acquiring token for Substrate using $($attempt.type): $($attempt.value)"
                if ($attempt.type -eq 'resource') {
                    if ($PSCmdlet.ParameterSetName -eq 'App') {
                        $tokenSubstrate = Get-O365OAuthToken -Tenant $Tenant -Resource $attempt.value -ClientId $ClientId -ClientSecret $ClientSecret -Certificate $Certificate -CertificatePassword $CertificatePassword
                    } else {
                        $tokenSubstrate = Get-O365OAuthToken -Tenant $Tenant -Resource $attempt.value -RefreshToken $refresh
                    }
                } else {
                    if ($PSCmdlet.ParameterSetName -eq 'App') {
                        $tokenSubstrate = Get-O365OAuthToken -Tenant $Tenant -Scope $attempt.value -ClientId $ClientId -ClientSecret $ClientSecret -Certificate $Certificate -CertificatePassword $CertificatePassword
                    } else {
                        $tokenSubstrate = Get-O365OAuthToken -Tenant $Tenant -Scope $attempt.value -RefreshToken $refresh
                    }
                }
            } catch {
                Write-Verbose -Message ("Connect-O365Admin - Substrate token attempt failed with: {0}" -f $_.Exception.Message)
                $tokenSubstrate = $null
            }
        }
        if (-not $tokenSubstrate) {
            Write-Verbose -Message "Connect-O365Admin - Substrate token not available. You can run Set-O365SubstrateAuth -SubstrateClientId <GUID> once to capture a reusable refresh token for the UI client."
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'App') {
        $userName = $ClientId
    } elseif ($Credential) {
        $userName = $Credential.UserName
    } else {
        $jwt = if ($tokenGraph.id_token) { $tokenGraph.id_token } else { $tokenGraph.access_token }
        $tokenInfo = ConvertFrom-JSONWebToken -Token $jwt
        $userName = if ($tokenInfo.preferred_username) { $tokenInfo.preferred_username } else { $tokenInfo.upn }
    }

    $Script:AuthorizationO365Cache = [ordered] @{
        'Credential'          = $Credential
        'ClientId'            = $ClientId
        'ClientSecret'        = $ClientSecret
        'Certificate'         = $Certificate
        'CertificatePassword' = $CertificatePassword
        'UserName'            = $userName
        'Environment'         = 'AzureCloud'
        'Subscription'        = $Subscription
        'Tenant'              = $Tenant
        'ExpiresOnUTC'        = ([datetime]::UtcNow).AddSeconds($ExpiresIn - $ExpiresTimeout)
        'RefreshToken'        = $refresh
        'AccessTokenO365'     = $tokenO365.access_token
        'HeadersO365'         = [ordered] @{
            'Content-Type'           = 'application/json; charset=UTF-8'
            'Authorization'          = "Bearer $($tokenO365.access_token)"
            'X-Requested-With'       = 'XMLHttpRequest'
            'x-ms-client-request-id' = [guid]::NewGuid()
            'x-ms-correlation-id'    = [guid]::NewGuid()
        }
        'AccessTokenAzure'    = if ($tokenAzure) { $tokenAzure.access_token } else { $null }
        'HeadersAzure'        = if ($tokenAzure) {
            [ordered] @{
                'Content-Type'           = 'application/json; charset=UTF-8'
                'Authorization'          = "Bearer $($tokenAzure.access_token)"
                'X-Requested-With'       = 'XMLHttpRequest'
                'x-ms-client-request-id' = [guid]::NewGuid()
                'x-ms-correlation-id'    = [guid]::NewGuid()
            }
        } else {
            $null
        }
        'AccessTokenARM'      = if ($tokenARM) { $tokenARM.access_token } else { $null }
        'HeadersARM'          = if ($tokenARM) {
            [ordered] @{
                'Content-Type'           = 'application/json; charset=UTF-8'
                'Authorization'          = "Bearer $($tokenARM.access_token)"
                'X-Requested-With'       = 'XMLHttpRequest'
                'x-ms-client-request-id' = [guid]::NewGuid()
                'x-ms-correlation-id'    = [guid]::NewGuid()
            }
        } else {
            $null
        }
        'AccessTokenGraph'    = $tokenGraph.access_token
        'HeadersGraph'        = [ordered] @{
            'Content-Type'           = 'application/json; charset=UTF-8'
            'Authorization'          = "Bearer $($tokenGraph.access_token)"
            'X-Requested-With'       = 'XMLHttpRequest'
            'x-ms-client-request-id' = [guid]::NewGuid()
            'x-ms-correlation-id'    = [guid]::NewGuid()
        }
        'AccessTokenTeams'    = if ($tokenTeams) { $tokenTeams.access_token } else { $null }
        'HeadersTeams'        = if ($tokenTeams) {
            [ordered] @{
                'Content-Type'           = 'application/json; charset=UTF-8'
                'Authorization'          = "Bearer $($tokenTeams.access_token)"
                'X-Requested-With'       = 'XMLHttpRequest'
                # Teams admin often validates origin/referer for CORS-like flows
                'Origin'                 = 'https://admin.teams.microsoft.com'
                'Referer'                = 'https://admin.teams.microsoft.com/'
                'x-ts-usecache'          = 'false'
                'x-serverrequestid'      = [guid]::NewGuid()
                'x-ms-client-request-id' = [guid]::NewGuid()
                'x-ms-correlation-id'    = [guid]::NewGuid()
            }
        } else {
            $null
        }
        'AccessTokenSubstrate' = if ($tokenSubstrate) { $tokenSubstrate.access_token } else { $null }
        'HeadersSubstrate'     = if ($tokenSubstrate) {
            [ordered] @{
                'Accept'                 = 'application/json'
                'Content-Type'           = 'application/json; charset=UTF-8'
                'Authorization'          = "Bearer $($tokenSubstrate.access_token)"
                'X-Requested-With'       = 'XMLHttpRequest'
                'x-ms-client-request-id' = [guid]::NewGuid()
                'x-ms-correlation-id'    = [guid]::NewGuid()
                'Origin'                 = 'https://admin.teams.microsoft.com'
                'Referer'                = 'https://admin.teams.microsoft.com/'
                'x-anchormailbox'        = "APP:AppAssignment_${Tenant}@${Tenant}"
                'x-ms-forest'            = '1e'
            }
        } else {
            $null
        }
        'PortalWebSession'     = $PortalWebSession
        'AjaxSessionKey'       = $AjaxSessionKey
        'PortalRouteKey'       = $PortalRouteKey
        'PortalUserId'         = $PortalUserId
        'PortalTenantId'       = $PortalTenantId
        'HeadersPortal'        = $HeadersPortal
    }

    if ($HasPortalAttachInput) {
        $PortalParams = @{
            Headers = $Script:AuthorizationO365Cache
        }
        if ($UsePortalAttachWebSession) {
            $PortalParams.WebSession = $PortalAttachWebSession
        } elseif ($UsePortalAttachCookies) {
            $PortalParams.RootAuthToken = $PortalAttachRootAuthToken
            if (-not [string]::IsNullOrWhiteSpace($PortalAttachSPAAuthCookie)) {
                $PortalParams.SPAAuthCookie = $PortalAttachSPAAuthCookie
            }
            if (-not [string]::IsNullOrWhiteSpace($PortalAttachOIDCAuthCookie)) {
                $PortalParams.OIDCAuthCookie = $PortalAttachOIDCAuthCookie
            }
            if (-not [string]::IsNullOrWhiteSpace($PortalAttachAjaxSessionKey)) {
                $PortalParams.AjaxSessionKey = $PortalAttachAjaxSessionKey
            }
            if (-not [string]::IsNullOrWhiteSpace($PortalAttachSessionId)) {
                $PortalParams.SessionId = $PortalAttachSessionId
            }
            if (-not [string]::IsNullOrWhiteSpace($PortalAttachTenantId)) {
                $PortalParams.TenantId = $PortalAttachTenantId
            }
            if (-not [string]::IsNullOrWhiteSpace($PortalAttachRouteKey)) {
                $PortalParams.PortalRouteKey = $PortalAttachRouteKey
            }
            if (-not [string]::IsNullOrWhiteSpace($PortalAttachUserName)) {
                $PortalParams.Username = $PortalAttachUserName
            }
            if ($PortalAttachCookieMap) {
                $PortalParams.AdditionalCookies = $PortalAttachCookieMap
            }
        }
        if ($SkipPortalBootstrap) {
            $PortalParams.SkipBootstrap = $true
        }

        return Set-O365PortalSession @PortalParams
    }

    $Script:AuthorizationO365Cache
}
