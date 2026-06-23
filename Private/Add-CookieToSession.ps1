function Add-CookieToSession {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][Microsoft.PowerShell.Commands.WebRequestSession] $Session,
        [Parameter(Mandatory)][string] $Name,
        [Parameter(Mandatory)][string] $Value,
        [Parameter(Mandatory)][string] $Domain
    )

    $Cookie = [System.Net.Cookie]::new($Name, $Value, '/', $Domain)
    $Session.Cookies.Add($Cookie)
}
