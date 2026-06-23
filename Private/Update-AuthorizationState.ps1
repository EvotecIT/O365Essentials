function Update-AuthorizationState {
    [cmdletbinding()]
    param(
        [System.Collections.IDictionary] $Target,
        [System.Collections.IDictionary] $Source,
        [string[]] $Key
    )

    if (-not $Target -or -not $Source -or [object]::ReferenceEquals($Target, $Source)) {
        return
    }

    $KeysToUpdate = if ($Key) { $Key } else { @($Source.Keys) }
    foreach ($Name in $KeysToUpdate) {
        if ($Source.Contains($Name)) {
            $Target[$Name] = $Source[$Name]
        }
    }
}
