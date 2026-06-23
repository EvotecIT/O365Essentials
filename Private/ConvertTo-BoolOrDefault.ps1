function ConvertTo-BoolOrDefault {
    [cmdletbinding()]
    param(
        [string] $Value,
        [bool] $Default = $false
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $Default
    }

    switch -Regex ($Value.Trim()) {
        '^(1|true|yes|y|on)$' { return $true }
        '^(0|false|no|n|off)$' { return $false }
        default { return $Default }
    }
}
