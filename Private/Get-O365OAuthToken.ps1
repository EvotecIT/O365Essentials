function Get-O365OAuthToken {
    [cmdletbinding()]
    param(
        [string] $Tenant = 'organizations',
        [string] $Scope,
        [string] $ClientId = '04b07795-8ddb-461a-bbee-02f9e1bf7b46',
        [PSCredential] $Credential,
        [switch] $Device
    )
    $tokenEndpoint = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/token"

    if ($Credential) {
        $body = @{
            client_id = $ClientId
            scope     = $Scope
            grant_type = 'password'
            username   = $Credential.UserName
            password   = $Credential.GetNetworkCredential().Password
        }
        return Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ContentType 'application/x-www-form-urlencoded'
    }

    if ($Device) {
        $deviceEndpoint = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/devicecode"
        $deviceBody = @{ client_id = $ClientId; scope = $Scope }
        $device = Invoke-RestMethod -Method Post -Uri $deviceEndpoint -Body $deviceBody -ContentType 'application/x-www-form-urlencoded'
        Write-Host $device.message
        $pollBody = @{ grant_type = 'urn:ietf:params:oauth:grant-type:device_code'; client_id = $ClientId; device_code = $device.device_code }
        do {
            Start-Sleep -Seconds $device.interval
            try {
                $result = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $pollBody -ContentType 'application/x-www-form-urlencoded'
            } catch {
                $result = $null
            }
        } until ($result)
        return $result
    }

    $verifierBytes = New-Object byte[] 32
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($verifierBytes)
    $codeVerifier = [System.Convert]::ToBase64String($verifierBytes).TrimEnd('=')
    $codeVerifier = $codeVerifier.Replace('+', '-').Replace('/', '_')
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $challengeBytes = $sha.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($codeVerifier))
    $codeChallenge = [System.Convert]::ToBase64String($challengeBytes).TrimEnd('=')
    $codeChallenge = $codeChallenge.Replace('+', '-').Replace('/', '_')
    $redirectUri = "http://localhost:8400/"
    $authorizeUrl = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/authorize?client_id=$ClientId&response_type=code&redirect_uri=$([System.Uri]::EscapeDataString($redirectUri))&response_mode=query&scope=$([System.Uri]::EscapeDataString($Scope))&code_challenge=$codeChallenge&code_challenge_method=S256"

    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add($redirectUri)
    $listener.Start()
    [System.Diagnostics.Process]::Start($authorizeUrl) | Out-Null
    $context = $listener.GetContext()
    $query = [System.Web.HttpUtility]::ParseQueryString($context.Request.Url.Query)
    $code = $query['code']
    $responseBytes = [System.Text.Encoding]::UTF8.GetBytes('<html><body>You may close this window.</body></html>')
    $context.Response.ContentLength64 = $responseBytes.Length
    $context.Response.OutputStream.Write($responseBytes,0,$responseBytes.Length)
    $context.Response.OutputStream.Close()
    $listener.Stop()

    $body = @{
        client_id    = $ClientId
        scope        = $Scope
        grant_type   = 'authorization_code'
        code         = $code
        redirect_uri = $redirectUri
        code_verifier = $codeVerifier
    }
    Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ContentType 'application/x-www-form-urlencoded'
}
