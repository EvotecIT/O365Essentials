function Resolve-PortalHeaderValue {
    [cmdletbinding()]
    param(
        [string] $Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $Value
    }

    if ($Value -match '%[0-9A-Fa-f]{2}') {
        try {
            return [System.Uri]::UnescapeDataString($Value)
        }
        catch {
            return $Value
        }
    }

    $Value
}
