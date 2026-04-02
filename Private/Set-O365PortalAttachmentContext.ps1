function Set-O365PortalAttachmentContext {
    <#
    .SYNOPSIS
    Seeds hidden portal attachment context for the next Connect-O365Admin call.

    .DESCRIPTION
    Stores admin.cloud.microsoft portal cookie artifacts in process-scoped environment
    variables so Connect-O365Admin can transparently attach a portal session without
    changing the end-user connection workflow.

    .PARAMETER WebSession
    Browser-derived admin.cloud.microsoft web session whose cookies should be converted
    into hidden portal attachment context.

    .PARAMETER CookieMap
    Dictionary-like collection containing cookie or portal session values. Common cookie
    names such as RootAuthToken, OIDCAuthCookie, SPAAuthCookie, s.AjaxSessionKey,
    s.SessID, s.UserTenantId, x-portal-routekey, and s.userid are supported.

    .PARAMETER Json
    JSON payload containing the same values accepted by CookieMap.

    .PARAMETER CookieHeader
    Raw HTTP Cookie header value containing the admin.cloud.microsoft portal cookies.

    .PARAMETER CookieList
    List of cookie objects that expose Name/Value or name/value properties, such as the
    browser cookie arrays often returned by automation frameworks.

    .PARAMETER RootAuthToken
    RootAuthToken cookie captured from admin.cloud.microsoft.

    .PARAMETER SPAAuthCookie
    Optional SPAAuthCookie captured from admin.cloud.microsoft.

    .PARAMETER OIDCAuthCookie
    Optional OIDCAuthCookie captured from admin.cloud.microsoft.

    .PARAMETER ClearAfterRead
    Controls whether Connect-O365Admin should clear the seeded values after consuming
    them. Defaults to True so portal artifacts are one-time-use unless explicitly kept.

    .EXAMPLE
    Set-O365PortalAttachmentContext -WebSession $portalSession
    Connect-O365Admin

    .EXAMPLE
    Set-O365PortalAttachmentContext -CookieMap $portalCookies
    Connect-O365Admin

    .EXAMPLE
    Set-O365PortalAttachmentContext -CookieHeader $cookieHeader
    Connect-O365Admin

    .EXAMPLE
    Set-O365PortalAttachmentContext -RootAuthToken $root -OIDCAuthCookie $oidc -AjaxSessionKey $ajax
    Connect-O365Admin
    #>
    [cmdletbinding(DefaultParameterSetName = 'Cookies')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'WebSession')][Microsoft.PowerShell.Commands.WebRequestSession] $WebSession,
        [Parameter(Mandatory, ParameterSetName = 'CookieMap')][System.Collections.IDictionary] $CookieMap,
        [Parameter(Mandatory, ParameterSetName = 'Json')][string] $Json,
        [Parameter(Mandatory, ParameterSetName = 'CookieHeader')][string] $CookieHeader,
        [Parameter(Mandatory, ParameterSetName = 'CookieList')][System.Collections.IEnumerable] $CookieList,
        [Parameter(Mandatory, ParameterSetName = 'Cookies')][string] $RootAuthToken,
        [Parameter(ParameterSetName = 'Cookies')][string] $SPAAuthCookie,
        [Parameter(ParameterSetName = 'Cookies')][string] $OIDCAuthCookie,
        [Parameter(ParameterSetName = 'Cookies')][string] $AjaxSessionKey,
        [Parameter(ParameterSetName = 'Cookies')][string] $SessionId,
        [Parameter(ParameterSetName = 'Cookies')][string] $TenantId,
        [Parameter(ParameterSetName = 'Cookies')][string] $PortalRouteKey,
        [Parameter(ParameterSetName = 'Cookies')][Alias('UserId')][string] $Username,
        [bool] $ClearAfterRead = $true,
        [switch] $SkipBootstrap
    )

    function Get-WebSessionCookieValue {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][Microsoft.PowerShell.Commands.WebRequestSession] $Session,
            [Parameter(Mandatory)][string] $Name
        )

        foreach ($CookieUri in @('https://admin.cloud.microsoft/', 'https://admin.cloud.microsoft/adminportal')) {
            $PortalCookies = $Session.Cookies.GetCookies($CookieUri)
            $Cookie = $PortalCookies | Where-Object Name -eq $Name | Select-Object -First 1
            if ($Cookie) {
                return $Cookie.Value
            }
        }
    }

    function Get-MappedPortalValue {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)] $Source,
            [Parameter(Mandatory)][string[]] $Names
        )

        foreach ($Name in $Names) {
            if ($Source -is [System.Collections.IDictionary]) {
                if ($Source.Contains($Name)) {
                    return $Source[$Name]
                }
            } elseif ($Source.PSObject -and $Source.PSObject.Properties[$Name]) {
                return $Source.PSObject.Properties[$Name].Value
            }
        }
    }

    function Convert-CookieHeaderToMap {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $Header
        )

        $Parsed = [ordered] @{}
        foreach ($Pair in ($Header -split ';')) {
            $TrimmedPair = $Pair.Trim()
            if ([string]::IsNullOrWhiteSpace($TrimmedPair)) {
                continue
            }
            $KeyValue = $TrimmedPair -split '=', 2
            if ($KeyValue.Count -lt 2) {
                continue
            }
            $Parsed[$KeyValue[0].Trim()] = $KeyValue[1].Trim()
        }
        $Parsed
    }

    function Convert-CookieListToMap {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][System.Collections.IEnumerable] $Cookies
        )

        $Parsed = [ordered] @{}
        foreach ($Cookie in $Cookies) {
            if ($null -eq $Cookie) {
                continue
            }

            $CookieName = Get-MappedPortalValue -Source $Cookie -Names @('Name', 'name')
            if ([string]::IsNullOrWhiteSpace($CookieName)) {
                continue
            }

            $CookieValue = Get-MappedPortalValue -Source $Cookie -Names @('Value', 'value')
            $Parsed[$CookieName] = $CookieValue
        }
        $Parsed
    }

    if ($PSCmdlet.ParameterSetName -eq 'WebSession') {
        $RootAuthToken = Get-WebSessionCookieValue -Session $WebSession -Name 'RootAuthToken'
        $SPAAuthCookie = Get-WebSessionCookieValue -Session $WebSession -Name 'SPAAuthCookie'
        $OIDCAuthCookie = Get-WebSessionCookieValue -Session $WebSession -Name 'OIDCAuthCookie'
        $AjaxSessionKey = Get-WebSessionCookieValue -Session $WebSession -Name 's.AjaxSessionKey'
        $SessionId = Get-WebSessionCookieValue -Session $WebSession -Name 's.SessID'
        $TenantId = Get-WebSessionCookieValue -Session $WebSession -Name 's.UserTenantId'
        $PortalRouteKey = Get-WebSessionCookieValue -Session $WebSession -Name 'x-portal-routekey'
        $Username = Get-WebSessionCookieValue -Session $WebSession -Name 's.userid'
    } elseif ($PSCmdlet.ParameterSetName -eq 'CookieMap' -or $PSCmdlet.ParameterSetName -eq 'Json' -or $PSCmdlet.ParameterSetName -eq 'CookieHeader' -or $PSCmdlet.ParameterSetName -eq 'CookieList') {
        $PortalSource = if ($PSCmdlet.ParameterSetName -eq 'Json') {
            try {
                ConvertFrom-Json -InputObject $Json -ErrorAction Stop
            } catch {
                Write-Error "Set-O365PortalAttachmentContext - Failed to parse Json input. $($_.Exception.Message)"
                return
            }
        } elseif ($PSCmdlet.ParameterSetName -eq 'CookieHeader') {
            Convert-CookieHeaderToMap -Header $CookieHeader
        } elseif ($PSCmdlet.ParameterSetName -eq 'CookieList') {
            Convert-CookieListToMap -Cookies $CookieList
        } else {
            $CookieMap
        }

        $RootAuthToken = Get-MappedPortalValue -Source $PortalSource -Names @('RootAuthToken', 'rootAuthToken')
        $SPAAuthCookie = Get-MappedPortalValue -Source $PortalSource -Names @('SPAAuthCookie', 'spaAuthCookie')
        $OIDCAuthCookie = Get-MappedPortalValue -Source $PortalSource -Names @('OIDCAuthCookie', 'oidcAuthCookie')
        $AjaxSessionKey = Get-MappedPortalValue -Source $PortalSource -Names @('AjaxSessionKey', 'ajaxSessionKey', 's.AjaxSessionKey')
        $SessionId = Get-MappedPortalValue -Source $PortalSource -Names @('SessionId', 'sessionId', 's.SessID')
        $TenantId = Get-MappedPortalValue -Source $PortalSource -Names @('TenantId', 'tenantId', 's.UserTenantId')
        $PortalRouteKey = Get-MappedPortalValue -Source $PortalSource -Names @('PortalRouteKey', 'portalRouteKey', 'x-portal-routekey')
        $Username = Get-MappedPortalValue -Source $PortalSource -Names @('Username', 'username', 'UserId', 'userId', 's.userid')
    }

    if ([string]::IsNullOrWhiteSpace($RootAuthToken)) {
        Write-Error 'Set-O365PortalAttachmentContext - RootAuthToken is required.'
        return
    }

    if ([string]::IsNullOrWhiteSpace($SPAAuthCookie) -and [string]::IsNullOrWhiteSpace($OIDCAuthCookie)) {
        Write-Error 'Set-O365PortalAttachmentContext - Provide at least one of SPAAuthCookie or OIDCAuthCookie.'
        return
    }

    $EnvironmentValues = [ordered] @{
        O365ESSENTIALS_PORTAL_ROOT_AUTH_TOKEN = $RootAuthToken
        O365ESSENTIALS_PORTAL_SPA_AUTH_COOKIE = $SPAAuthCookie
        O365ESSENTIALS_PORTAL_OIDC_AUTH_COOKIE = $OIDCAuthCookie
        O365ESSENTIALS_PORTAL_AJAX_SESSION_KEY = $AjaxSessionKey
        O365ESSENTIALS_PORTAL_SESSION_ID = $SessionId
        O365ESSENTIALS_PORTAL_TENANT_ID = $TenantId
        O365ESSENTIALS_PORTAL_ROUTE_KEY = $PortalRouteKey
        O365ESSENTIALS_PORTAL_USERNAME = $Username
        O365ESSENTIALS_PORTAL_SKIP_BOOTSTRAP = if ($SkipBootstrap) { 'true' } else { $null }
        O365ESSENTIALS_PORTAL_CLEAR_AFTER_READ = if ($ClearAfterRead) { 'true' } else { 'false' }
    }

    foreach ($Entry in @($EnvironmentValues.GetEnumerator())) {
        [Environment]::SetEnvironmentVariable($Entry.Key, $Entry.Value, 'Process')
    }

    [PSCustomObject] @{
        RootAuthTokenPresent = $true
        SPAAuthCookiePresent = -not [string]::IsNullOrWhiteSpace($SPAAuthCookie)
        OIDCAuthCookiePresent = -not [string]::IsNullOrWhiteSpace($OIDCAuthCookie)
        AjaxSessionKeyPresent = -not [string]::IsNullOrWhiteSpace($AjaxSessionKey)
        SessionIdPresent = -not [string]::IsNullOrWhiteSpace($SessionId)
        TenantIdPresent = -not [string]::IsNullOrWhiteSpace($TenantId)
        PortalRouteKeyPresent = -not [string]::IsNullOrWhiteSpace($PortalRouteKey)
        UsernamePresent = -not [string]::IsNullOrWhiteSpace($Username)
        SkipBootstrap = [bool] $SkipBootstrap
        ClearAfterRead = $ClearAfterRead
    }
}
