function Initialize-O365PortalWebSession {
    <#
    .SYNOPSIS
    Replays a lightweight admin.cloud.microsoft bootstrap sequence for a portal web session.

    .DESCRIPTION
    Uses an existing admin.cloud.microsoft cookie-backed session to visit a small set of
    portal routes and recover session cookie values such as AjaxSessionKey and
    x-portal-routekey when available.
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][Microsoft.PowerShell.Commands.WebRequestSession] $WebSession,
        [string] $UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36'
    )

    function Get-PortalCookieValue {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)][string] $Name
        )

        foreach ($CookieUri in @('https://admin.cloud.microsoft/', 'https://admin.cloud.microsoft/adminportal')) {
            $PortalCookies = $WebSession.Cookies.GetCookies($CookieUri)
            $Cookie = $PortalCookies | Where-Object Name -eq $Name | Select-Object -First 1
            if ($Cookie) {
                return $Cookie.Value
            }
        }
    }

    if ($UserAgent) {
        $WebSession.UserAgent = $UserAgent
    }

    $DocumentHeaders = @{
        Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8'
    }

    foreach ($Uri in @(
            'https://admin.cloud.microsoft/adminportal?ref=/homepage',
            'https://admin.cloud.microsoft/?ref=/homepage'
        )) {
        try {
            $null = Invoke-WebRequest -MaximumRedirection 20 -ErrorAction Stop -WebSession $WebSession -Method Get -Uri $Uri -Headers $DocumentHeaders -UserAgent $UserAgent
        } catch {
            Write-Verbose "Initialize-O365PortalWebSession - Bootstrap request failed for '$Uri'. $($_.Exception.Message)"
        }
    }

    $AjaxSessionKey = Get-PortalCookieValue -Name 's.AjaxSessionKey'
    $PortalRouteKey = Get-PortalCookieValue -Name 'x-portal-routekey'

    if (-not [string]::IsNullOrWhiteSpace($AjaxSessionKey)) {
        try {
            $null = Invoke-WebRequest -MaximumRedirection 20 -ErrorAction Stop -WebSession $WebSession -Method Get -Uri 'https://admin.cloud.microsoft/adminportal/home/ClassicModernAdminDataStream?ref=/homepage' -Headers (Get-O365PortalContextHeaders -Context Homepage -PortalHost 'https://admin.cloud.microsoft' -AjaxSessionKey $AjaxSessionKey -PortalRouteKey $PortalRouteKey) -UserAgent $UserAgent
        } catch {
            Write-Verbose "Initialize-O365PortalWebSession - ClassicModernAdminDataStream bootstrap request failed. $($_.Exception.Message)"
        }

        try {
            $null = Invoke-WebRequest -MaximumRedirection 20 -ErrorAction Stop -WebSession $WebSession -Method Get -Uri 'https://admin.cloud.microsoft/admin/api/tenant/datalocationandcommitments' -Headers (Get-O365PortalContextHeaders -Context DataLocation -PortalHost 'https://admin.cloud.microsoft' -AjaxSessionKey $AjaxSessionKey -PortalRouteKey $PortalRouteKey) -UserAgent $UserAgent
        } catch {
            Write-Verbose "Initialize-O365PortalWebSession - Data location bootstrap request failed. $($_.Exception.Message)"
        }
    }

    [PSCustomObject] @{
        WebSession     = $WebSession
        AjaxSessionKey = (Get-PortalCookieValue -Name 's.AjaxSessionKey')
        PortalRouteKey = (Get-PortalCookieValue -Name 'x-portal-routekey')
        TenantId       = (Get-PortalCookieValue -Name 's.UserTenantId')
        UserId         = (Get-PortalCookieValue -Name 's.userid')
    }
}
