function Get-O365OAuthToken {
    [cmdletbinding()]
    param(
        [string] $Tenant = 'organizations',
        [string] $Scope,
        [string] $ClientId = '74658136-14ec-4630-ad9b-26e160ff0fc6',
        [PSCredential] $Credential
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
    } else {
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
}
