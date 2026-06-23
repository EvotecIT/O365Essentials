function Get-O365PortalAttachmentContext {
    <#
    .SYNOPSIS
    Retrieves pending portal session artifacts supplied by the current host process.

    .DESCRIPTION
    Reads process-scoped environment variables used by callers that want Connect-O365Admin
    to attach an admin.cloud.microsoft portal session without exposing a second public
    connection step to end users.
    #>
    [cmdletbinding()]
    param()

    $EnvironmentMap = [ordered] @{
        RootAuthToken  = 'O365ESSENTIALS_PORTAL_ROOT_AUTH_TOKEN'
        SPAAuthCookie  = 'O365ESSENTIALS_PORTAL_SPA_AUTH_COOKIE'
        OIDCAuthCookie = 'O365ESSENTIALS_PORTAL_OIDC_AUTH_COOKIE'
        AjaxSessionKey = 'O365ESSENTIALS_PORTAL_AJAX_SESSION_KEY'
        SessionId      = 'O365ESSENTIALS_PORTAL_SESSION_ID'
        TenantId       = 'O365ESSENTIALS_PORTAL_TENANT_ID'
        PortalRouteKey = 'O365ESSENTIALS_PORTAL_ROUTE_KEY'
        Username       = 'O365ESSENTIALS_PORTAL_USERNAME'
    }

    $Values = [ordered] @{}
    foreach ($Entry in @($EnvironmentMap.GetEnumerator())) {
        $Values[$Entry.Key] = Get-ProcessEnvironmentValue -Name $Entry.Value
    }

    $PortalSourceJson = Get-ProcessEnvironmentValue -Name 'O365ESSENTIALS_PORTAL_CONTEXT_JSON'
    $PortalCookieHeader = Get-ProcessEnvironmentValue -Name 'O365ESSENTIALS_PORTAL_COOKIE_HEADER'
    $PortalCookieListJson = Get-ProcessEnvironmentValue -Name 'O365ESSENTIALS_PORTAL_COOKIE_LIST_JSON'
    $PortalCookieMap = $null

    if ([string]::IsNullOrWhiteSpace($Values.RootAuthToken) -and (-not [string]::IsNullOrWhiteSpace($PortalSourceJson) -or -not [string]::IsNullOrWhiteSpace($PortalCookieHeader) -or -not [string]::IsNullOrWhiteSpace($PortalCookieListJson))) {
        $PortalSource = $null
        if (-not [string]::IsNullOrWhiteSpace($PortalSourceJson)) {
            try {
                $PortalSource = ConvertFrom-Json -InputObject $PortalSourceJson -ErrorAction Stop
            }
            catch {
                Write-Verbose "Get-O365PortalAttachmentContext - Failed to parse O365ESSENTIALS_PORTAL_CONTEXT_JSON. $($_.Exception.Message)"
            }
        }
        elseif (-not [string]::IsNullOrWhiteSpace($PortalCookieHeader)) {
            $PortalSource = Convert-CookieHeaderToMap -Header $PortalCookieHeader
        }
        elseif (-not [string]::IsNullOrWhiteSpace($PortalCookieListJson)) {
            try {
                $PortalCookieList = ConvertFrom-Json -InputObject $PortalCookieListJson -ErrorAction Stop
                $PortalSource = Convert-CookieListToMap -Cookies $PortalCookieList
            }
            catch {
                Write-Verbose "Get-O365PortalAttachmentContext - Failed to parse O365ESSENTIALS_PORTAL_COOKIE_LIST_JSON. $($_.Exception.Message)"
            }
        }

        if ($PortalSource) {
            $PortalCookieMap = Convert-PortalSourceToMap -Source $PortalSource
            $Values.RootAuthToken = Get-MappedPortalValue -Source $PortalSource -Names @('RootAuthToken', 'rootAuthToken')
            $Values.SPAAuthCookie = Get-MappedPortalValue -Source $PortalSource -Names @('SPAAuthCookie', 'spaAuthCookie')
            $Values.OIDCAuthCookie = Get-MappedPortalValue -Source $PortalSource -Names @('OIDCAuthCookie', 'oidcAuthCookie')
            $Values.AjaxSessionKey = Get-MappedPortalValue -Source $PortalSource -Names @('AjaxSessionKey', 'ajaxSessionKey', 's.AjaxSessionKey')
            $Values.SessionId = Get-MappedPortalValue -Source $PortalSource -Names @('SessionId', 'sessionId', 's.SessID')
            $Values.TenantId = Get-MappedPortalValue -Source $PortalSource -Names @('TenantId', 'tenantId', 's.UserTenantId')
            $Values.PortalRouteKey = Get-MappedPortalValue -Source $PortalSource -Names @('PortalRouteKey', 'portalRouteKey', 'x-portal-routekey')
            $Values.Username = Get-MappedPortalValue -Source $PortalSource -Names @('Username', 'username', 'UserId', 'userId', 's.userid')
        }
    }

    $HasCookieSeed = -not [string]::IsNullOrWhiteSpace($Values.RootAuthToken) -and (
        -not [string]::IsNullOrWhiteSpace($Values.OIDCAuthCookie) -or
        -not [string]::IsNullOrWhiteSpace($Values.SPAAuthCookie)
    )

    if (-not $HasCookieSeed) {
        return $null
    }

    if (-not $PortalCookieMap) {
        $PortalCookieMap = [ordered] @{}
        if (-not [string]::IsNullOrWhiteSpace($Values.RootAuthToken)) { $PortalCookieMap['RootAuthToken'] = $Values.RootAuthToken }
        if (-not [string]::IsNullOrWhiteSpace($Values.SPAAuthCookie)) { $PortalCookieMap['SPAAuthCookie'] = $Values.SPAAuthCookie }
        if (-not [string]::IsNullOrWhiteSpace($Values.OIDCAuthCookie)) { $PortalCookieMap['OIDCAuthCookie'] = $Values.OIDCAuthCookie }
        if (-not [string]::IsNullOrWhiteSpace($Values.AjaxSessionKey)) { $PortalCookieMap['s.AjaxSessionKey'] = $Values.AjaxSessionKey }
        if (-not [string]::IsNullOrWhiteSpace($Values.SessionId)) { $PortalCookieMap['s.SessID'] = $Values.SessionId }
        if (-not [string]::IsNullOrWhiteSpace($Values.TenantId)) { $PortalCookieMap['s.UserTenantId'] = $Values.TenantId }
        if (-not [string]::IsNullOrWhiteSpace($Values.PortalRouteKey)) { $PortalCookieMap['x-portal-routekey'] = $Values.PortalRouteKey }
        if (-not [string]::IsNullOrWhiteSpace($Values.Username)) { $PortalCookieMap['s.userid'] = $Values.Username }
    }

    $SkipBootstrap = ConvertTo-BoolOrDefault -Value (Get-ProcessEnvironmentValue -Name 'O365ESSENTIALS_PORTAL_SKIP_BOOTSTRAP')
    $ClearAfterRead = ConvertTo-BoolOrDefault -Value (Get-ProcessEnvironmentValue -Name 'O365ESSENTIALS_PORTAL_CLEAR_AFTER_READ') -Default $true

    if ($ClearAfterRead) {
        foreach ($EnvironmentName in @($EnvironmentMap.Values + 'O365ESSENTIALS_PORTAL_SKIP_BOOTSTRAP', 'O365ESSENTIALS_PORTAL_CLEAR_AFTER_READ', 'O365ESSENTIALS_PORTAL_CONTEXT_JSON', 'O365ESSENTIALS_PORTAL_COOKIE_HEADER', 'O365ESSENTIALS_PORTAL_COOKIE_LIST_JSON')) {
            Remove-ProcessEnvironmentValue -Name $EnvironmentName
        }
    }

    [PSCustomObject] @{
        RootAuthToken  = $Values.RootAuthToken
        SPAAuthCookie  = $Values.SPAAuthCookie
        OIDCAuthCookie = $Values.OIDCAuthCookie
        AjaxSessionKey = $Values.AjaxSessionKey
        SessionId      = $Values.SessionId
        TenantId       = $Values.TenantId
        PortalRouteKey = $Values.PortalRouteKey
        Username       = $Values.Username
        CookieMap      = $PortalCookieMap
        SkipBootstrap  = $SkipBootstrap
    }
}
