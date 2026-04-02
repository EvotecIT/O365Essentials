function Get-O365PortalContextHeaders {
    <#
    .SYNOPSIS
    Builds reusable Microsoft 365 admin portal headers for context-sensitive routes.

    .DESCRIPTION
    Some internal admin center endpoints behave differently depending on portal route context.
    This helper returns a small header set that can be merged into Invoke-O365Admin calls.
    The values here intentionally mirror the current admin.cloud.microsoft portal shape so
    token-backed requests and cookie-backed replay stay aligned with the live browser.

    .PARAMETER Context
    The admin center experience the request belongs to.

    .PARAMETER AjaxSessionKey
    Optional Ajax session key to include when a route requires it.

    .PARAMETER PortalRouteKey
    Optional portal route key cookie value used by some admin.cloud.microsoft requests.

    .PARAMETER PortalHost
    Base Microsoft 365 admin portal host. Defaults to https://admin.microsoft.com.

    .EXAMPLE
    Get-O365PortalContextHeaders -Context Agents
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('Agents', 'Backup', 'BrandCenter', 'Copilot', 'DataLocation', 'Homepage', 'IntegratedApps', 'MicrosoftEdge', 'MicrosoftSearch', 'PayAsYouGo', 'People', 'Viva')][string] $Context,
        [string] $AjaxSessionKey,
        [string] $PortalRouteKey,
        [string] $PortalHost = 'https://admin.microsoft.com'
    )

    $MacAppId = '8788975c-133f-4d33-acb5-3fb1ba00e746'
    $MacVersion = 'host-mac_2026.3.26.4'

    $Headers = [ordered] @{
        Accept                  = 'application/json;odata=minimalmetadata, text/plain, */*'
        'Cache-Control'         = 'no-cache'
        Pragma                  = 'no-cache'
        'x-edge-shopping-flag'  = '1'
        'x-ms-mac-appid'        = $MacAppId
        'x-ms-mac-hostingapp'   = 'M365AdminPortal'
        'x-ms-mac-hosting-app'  = 'M365AdminPortal'
        'x-ms-mac-target-app'   = 'MAC'
        'x-ms-mac-version'      = $MacVersion
    }

    switch ($Context) {
        'Homepage' {
            $Headers['Referer'] = "$PortalHost/?"
            $Headers['x-adminapp-request'] = '/homepage'
        }
        'MicrosoftSearch' {
            $Headers['Referer'] = "$PortalHost/"
            $Headers['x-adminapp-request'] = '/MicrosoftSearch'
        }
        'Viva' {
            $Headers['Referer'] = "$PortalHost/"
            $Headers['x-adminapp-request'] = '/viva'
        }
        'DataLocation' {
            $Headers['Referer'] = "$PortalHost/"
            $Headers['x-adminapp-request'] = '/Settings/OrganizationProfile/:/Settings/L1/DataLocation'
        }
        'Agents' {
            $Headers['Referer'] = "$PortalHost/"
            $Headers['x-adminapp-request'] = '/Agents'
        }
        'Backup' {
            $Headers['Referer'] = "$PortalHost/"
            $Headers['x-adminapp-request'] = '/Settings/enhancedRestore'
        }
        'Copilot' {
            $Headers['Referer'] = "$PortalHost/"
            $Headers['x-adminapp-request'] = '/Copilot'
        }
        'IntegratedApps' {
            $Headers['Referer'] = "$PortalHost/"
            $Headers['x-adminapp-request'] = '/Settings/IntegratedApps'
        }
        'MicrosoftEdge' {
            $Headers['Referer'] = "$PortalHost/"
        }
        'BrandCenter' {
            $Headers['Referer'] = "$PortalHost/"
        }
        'PayAsYouGo' {
            $Headers['Referer'] = "$PortalHost/"
            $Headers['x-adminapp-request'] = '/orgsettings/payasyougo'
        }
        'People' {
            $Headers['Referer'] = "$PortalHost/"
            $Headers['x-adminapp-request'] = '/Settings/OrgSettings/People'
        }
    }

    if ($AjaxSessionKey) {
        $Headers['AjaxSessionKey'] = $AjaxSessionKey
    }
    if ($PortalRouteKey) {
        $Headers['x-portal-routekey'] = $PortalRouteKey
    }
    $Headers
}
