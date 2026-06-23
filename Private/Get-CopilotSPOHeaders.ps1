function Get-CopilotSPOHeaders {
    [cmdletbinding()]
    param()

    $SPOHeaders = [ordered] @{}
    foreach ($Key in $AdditionalHeaders.Keys) {
        $SPOHeaders[$Key] = $AdditionalHeaders[$Key]
    }
    $SPOHeaders['Accept'] = 'application/json'
    $SPOHeaders['odata-version'] = '4.0'
    $SPOHeaders['x-ms-mac-target-app'] = 'SPO'
    $SPOHeaders
}
