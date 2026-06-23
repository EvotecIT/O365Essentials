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
