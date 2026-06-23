function Get-WebSessionCookieValue {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][Microsoft.PowerShell.Commands.WebRequestSession] $Session,
        [Parameter(Mandatory)][string] $Name
    )

    foreach ($CookieUri in @('https://admin.cloud.microsoft/', 'https://admin.cloud.microsoft/adminportal')) {
        $PortalCookies = $Session.Cookies.GetCookies($CookieUri)
        $Cookie = $PortalCookies | Where-Object Name -EQ $Name | Select-Object -First 1
        if ($Cookie) {
            return $Cookie.Value
        }
    }
}
