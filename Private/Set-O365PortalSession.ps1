function Set-O365PortalSession {
    <#
    .SYNOPSIS
    Attaches an admin.cloud.microsoft portal session to the current O365Essentials connection.

    .DESCRIPTION
    Accepts either a browser-derived WebRequestSession or the core admin.cloud.microsoft
    cookies, then stores the resulting portal session metadata inside the current
    O365Essentials authorization cache. Cmdlets that support portal-session replay can
    then use the cookie-backed session instead of bearer-token-only requests.
    #>
    [cmdletbinding(DefaultParameterSetName = 'WebSession')]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory, ParameterSetName = 'WebSession')][Microsoft.PowerShell.Commands.WebRequestSession] $WebSession,
        [Parameter(Mandatory, ParameterSetName = 'Cookies')][string] $RootAuthToken,
        [Parameter(ParameterSetName = 'Cookies')][string] $SPAAuthCookie,
        [Parameter(ParameterSetName = 'Cookies')][string] $OIDCAuthCookie,
        [Parameter(ParameterSetName = 'Cookies')][string] $AjaxSessionKey,
        [Parameter(ParameterSetName = 'Cookies')][string] $SessionId,
        [Parameter(ParameterSetName = 'Cookies')][string] $TenantId,
        [Parameter(ParameterSetName = 'Cookies')][string] $PortalRouteKey,
        [Parameter(ParameterSetName = 'Cookies')][Alias('UserId')][string] $Username,
        [System.Collections.IDictionary] $AdditionalCookies,
        [string] $UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36',
        [switch] $SkipBootstrap
    )

    $BaseHeaders = if ($Headers) {
        Connect-O365Admin -Headers $Headers
    }
    elseif ($Script:AuthorizationO365Cache) {
        Connect-O365Admin -Headers $Script:AuthorizationO365Cache
    }
    else {
        [ordered] @{}
    }

    $ResolvedHeaders = Copy-AuthorizationState -Source $BaseHeaders

    $ResolvedWebSession = if ($PSCmdlet.ParameterSetName -eq 'WebSession') {
        if ($UserAgent) {
            $WebSession.UserAgent = $UserAgent
        }
        $WebSession
    }
    else {
        $Session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
        $Session.UserAgent = $UserAgent

        if ($AdditionalCookies) {
            Add-CookieMapToSession -Session $Session -CookieMap $AdditionalCookies -Domain 'admin.cloud.microsoft'
        }

        Add-CookieToSession -Session $Session -Name 'RootAuthToken' -Value $RootAuthToken -Domain 'admin.cloud.microsoft'
        if (-not [string]::IsNullOrWhiteSpace($SPAAuthCookie)) {
            Add-CookieToSession -Session $Session -Name 'SPAAuthCookie' -Value $SPAAuthCookie -Domain 'admin.cloud.microsoft'
        }
        if (-not [string]::IsNullOrWhiteSpace($OIDCAuthCookie)) {
            Add-CookieToSession -Session $Session -Name 'OIDCAuthCookie' -Value $OIDCAuthCookie -Domain 'admin.cloud.microsoft'
        }
        if ($AjaxSessionKey) {
            Add-CookieToSession -Session $Session -Name 's.AjaxSessionKey' -Value $AjaxSessionKey -Domain 'admin.cloud.microsoft'
        }
        if ($SessionId) {
            Add-CookieToSession -Session $Session -Name 's.SessID' -Value $SessionId -Domain 'admin.cloud.microsoft'
        }
        if ($TenantId) {
            Add-CookieToSession -Session $Session -Name 's.UserTenantId' -Value $TenantId -Domain 'admin.cloud.microsoft'
        }
        if ($Username) {
            Add-CookieToSession -Session $Session -Name 's.userid' -Value $Username -Domain 'admin.cloud.microsoft'
        }
        if ($PortalRouteKey) {
            Add-CookieToSession -Session $Session -Name 'x-portal-routekey' -Value $PortalRouteKey -Domain 'admin.cloud.microsoft'
        }
        $Session
    }

    $BootstrapState = if ($SkipBootstrap) {
        [PSCustomObject] @{
            WebSession     = $ResolvedWebSession
            AjaxSessionKey = $AjaxSessionKey
            PortalRouteKey = $PortalRouteKey
            TenantId       = $TenantId
            UserId         = $Username
        }
    }
    else {
        Initialize-O365PortalWebSession -WebSession $ResolvedWebSession -UserAgent $UserAgent
    }

    $NormalizedAjaxSessionKey = Resolve-PortalHeaderValue -Value $BootstrapState.AjaxSessionKey
    $NormalizedPortalRouteKey = Resolve-PortalHeaderValue -Value $BootstrapState.PortalRouteKey
    $NormalizedTenantId = Resolve-PortalHeaderValue -Value $BootstrapState.TenantId
    $NormalizedUserId = Resolve-PortalHeaderValue -Value $BootstrapState.UserId

    $HeadersPortal = [ordered] @{
        Accept                 = 'application/json;odata=minimalmetadata, text/plain, */*'
        'Cache-Control'        = 'no-cache'
        Pragma                 = 'no-cache'
        'x-edge-shopping-flag' = '1'
        'x-ms-mac-appid'       = '8788975c-133f-4d33-acb5-3fb1ba00e746'
        'x-ms-mac-hostingapp'  = 'M365AdminPortal'
        'x-ms-mac-hosting-app' = 'M365AdminPortal'
        'x-ms-mac-target-app'  = 'MAC'
        'x-ms-mac-version'     = 'host-mac_2026.3.26.4'
    }
    if ($NormalizedAjaxSessionKey) {
        $HeadersPortal['AjaxSessionKey'] = $NormalizedAjaxSessionKey
    }
    if ($NormalizedPortalRouteKey) {
        $HeadersPortal['x-portal-routekey'] = $NormalizedPortalRouteKey
    }

    $ResolvedHeaders['PortalWebSession'] = $BootstrapState.WebSession
    $ResolvedHeaders['AjaxSessionKey'] = $NormalizedAjaxSessionKey
    $ResolvedHeaders['PortalRouteKey'] = $NormalizedPortalRouteKey
    $ResolvedHeaders['PortalUserId'] = $NormalizedUserId
    $ResolvedHeaders['PortalTenantId'] = $NormalizedTenantId
    $ResolvedHeaders['HeadersPortal'] = $HeadersPortal

    $Script:AuthorizationO365Cache = $ResolvedHeaders
    $ResolvedHeaders
}
