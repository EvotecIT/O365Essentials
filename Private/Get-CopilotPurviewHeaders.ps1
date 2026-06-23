function Get-CopilotPurviewHeaders {
    [cmdletbinding()]
    param(
        [switch] $IncludeClientRequestId
    )

    $PurviewHeaders = [ordered] @{
        tenantid             = $TenantId
        'x-tid'              = $TenantId
        'client-type'        = 'purview'
        'x-clientpage'       = '/'
        'client-version'     = '1.0.2774.1'
        'x-tabvisible'       = 'visible'
        'x-clientpkgversion' = ''
    }

    if ($IncludeClientRequestId) {
        $PurviewHeaders['client-request-id'] = [guid]::NewGuid().ToString()
    }

    foreach ($Key in $AdditionalHeaders.Keys) {
        $PurviewHeaders[$Key] = $AdditionalHeaders[$Key]
    }

    $PurviewHeaders
}
