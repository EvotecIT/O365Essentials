function Copy-AuthorizationState {
    [cmdletbinding()]
    param(
        [System.Collections.IDictionary] $Source
    )

    $Clone = [ordered] @{}
    if ($Source) {
        foreach ($Entry in @($Source.GetEnumerator())) {
            $Clone[$Entry.Key] = $Entry.Value
        }
    }
    $Clone
}
