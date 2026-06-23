function Add-CookieMapToSession {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][Microsoft.PowerShell.Commands.WebRequestSession] $Session,
        [Parameter(Mandatory)][System.Collections.IDictionary] $CookieMap,
        [Parameter(Mandatory)][string] $Domain
    )

    foreach ($Entry in @($CookieMap.GetEnumerator())) {
        $CookieName = [string] $Entry.Key
        $CookieValue = [string] $Entry.Value
        if ([string]::IsNullOrWhiteSpace($CookieName) -or [string]::IsNullOrWhiteSpace($CookieValue)) {
            continue
        }
        Add-CookieToSession -Session $Session -Name $CookieName -Value $CookieValue -Domain $Domain
    }
}
