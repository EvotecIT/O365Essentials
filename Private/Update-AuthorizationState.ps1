function Update-AuthorizationState {
    [cmdletbinding()]
    param(
        [System.Collections.IDictionary] $Target,
        [System.Collections.IDictionary] $Source
    )

    if (-not $Target -or -not $Source -or [object]::ReferenceEquals($Target, $Source)) {
        return
    }

    foreach ($Key in @($Target.Keys)) {
        if (-not $Source.Contains($Key)) {
            $Target.Remove($Key)
        }
    }
    foreach ($Entry in @($Source.GetEnumerator())) {
        $Target[$Entry.Key] = $Entry.Value
    }
}
