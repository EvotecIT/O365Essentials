function Get-O365OAuthToken {
    [cmdletbinding()]
    param(
        [string] $Tenant = 'organizations',
        [string] $Scope,
        # Azure PowerShell public client ID - used for interactive sign in
        [string] $ClientId = '04b07795-8ddb-461a-bbee-02f9e1bf7b46',
        [PSCredential] $Credential,
        [string] $RefreshToken,
        [switch] $Device,
        [string] $ClientSecret,
        $Certificate
    )
    $tokenEndpoint = "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/token"

    if ($ClientSecret -or $Certificate) {
        if ($Certificate -and ($Certificate -isnot [System.Security.Cryptography.X509Certificates.X509Certificate2])) {
            if (Test-Path $Certificate) {
                $Certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new((Resolve-Path $Certificate))
            } else {
                throw "Certificate path '$Certificate' not found"
            }
        }

        function ConvertTo-Base64Url([byte[]] $bytes) {
            [Convert]::ToBase64String($bytes).TrimEnd('=')
            | ForEach-Object { $_.Replace('+', '-').Replace('/', '_') }
        }

        $body = @{ client_id = $ClientId; scope = $Scope; grant_type = 'client_credentials' }
        if ($ClientSecret) {
            $body.client_secret = $ClientSecret
        } elseif ($Certificate) {
            $now = Get-Date
            $header = @{ alg = 'RS256'; typ = 'JWT' }
            $payload = @{
                aud = $tokenEndpoint
                iss = $ClientId
                sub = $ClientId
                jti = [guid]::NewGuid().Guid
                nbf = [int][Math]::Floor(($now.AddMinutes(-5)  - (Get-Date '1970-01-01Z')).TotalSeconds)
                exp = [int][Math]::Floor(($now.AddMinutes(10) - (Get-Date '1970-01-01Z')).TotalSeconds)
            }
            $headerEnc  = ConvertTo-Base64Url([System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $header -Compress)))
            $payloadEnc = ConvertTo-Base64Url([System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $payload -Compress)))
            $unsigned   = "$headerEnc.$payloadEnc"
            $rsa = $Certificate.GetRSAPrivateKey()
            $signature = $rsa.SignData([System.Text.Encoding]::UTF8.GetBytes($unsigned), [System.Security.Cryptography.HashAlgorithmName]::SHA256, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)
            $signed = "$unsigned.$(ConvertTo-Base64Url($signature))"
            $body.client_assertion_type = 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
            $body.client_assertion = $signed
        }
        return Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ContentType 'application/x-www-form-urlencoded'
    }

    if ($RefreshToken) {
        $body = @{
            client_id     = $ClientId
            scope         = $Scope
            grant_type    = 'refresh_token'
            refresh_token = $RefreshToken
        }
        return Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ContentType 'application/x-www-form-urlencoded'
    }

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
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($verifierBytes)
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
    try {
        if ($IsWindows) {
            Start-Process $authorizeUrl
        } elseif ($IsMacOS) {
            if (Get-Command open -ErrorAction SilentlyContinue) { open $authorizeUrl }
        } elseif (Get-Command xdg-open -ErrorAction SilentlyContinue) {
            xdg-open $authorizeUrl
        } else {
            Write-Host "Open $authorizeUrl in your browser to authenticate"
        }
    } catch {
        Write-Verbose "Unable to automatically open browser: $($_.Exception.Message)"
        Write-Host "Open $authorizeUrl in your browser to authenticate"
    }
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
