function Get-PortalCookieValue {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $Name
    )

    foreach ($CookieUri in @('https://admin.cloud.microsoft/', 'https://admin.cloud.microsoft/adminportal')) {
        $PortalCookies = $WebSession.Cookies.GetCookies($CookieUri)
        $Cookie = $PortalCookies | Where-Object Name -EQ $Name | Select-Object -First 1
        if ($Cookie) {
            return $Cookie.Value
        }
    }
}
