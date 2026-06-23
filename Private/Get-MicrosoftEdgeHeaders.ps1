function Get-MicrosoftEdgeHeaders {
    [cmdletbinding()]
    param(
        [hashtable] $ExtraHeaders
    )

    $HeadersToSend = [ordered] @{}
    foreach ($Key in $AdditionalHeaders.Keys) {
        $HeadersToSend[$Key] = $AdditionalHeaders[$Key]
    }

    if ($ExtraHeaders) {
        foreach ($Key in $ExtraHeaders.Keys) {
            $HeadersToSend[$Key] = $ExtraHeaders[$Key]
        }
    }

    $HeadersToSend
}
