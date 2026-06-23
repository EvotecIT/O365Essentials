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
