function Connect-O365Admin {
    [cmdletbinding(DefaultParameterSetName = 'Credential')]
    param(
        [parameter(ParameterSetName = 'Credential')][PSCredential] $Credential,
        [parameter(ParameterSetName = 'Headers', DontShow)][alias('Authorization')][System.Collections.IDictionary] $Headers,
        [int] $ExpiresIn = 3600,
        [int] $ExpiresTimeout = 30,
        [switch] $ForceRefresh,
        [switch] $Device,
        [alias('TenantID')][string] $Tenant,
        [string] $DomainName,
        [string] $Subscription
    )

    $RefreshToken = $null
    if ($Headers) {
        if ($Headers.ExpiresOnUTC -gt [datetime]::UtcNow -and -not $ForceRefresh) {
            Write-Verbose -Message "Connect-O365Admin - Using cache for connection $($Headers.UserName)"
            return $Headers
        } else {
            $Credential   = $Headers.Credential
            $Tenant       = $Headers.Tenant
            $Subscription = $Headers.Subscription
            $RefreshToken = $Headers.RefreshToken
        }
    } elseif ($Script:AuthorizationO365Cache) {
        if ($Script:AuthorizationO365Cache.ExpiresOnUTC -gt [datetime]::UtcNow -and -not $ForceRefresh) {
            Write-Verbose -Message "Connect-O365Admin - Using cache for connection $($Script:AuthorizationO365Cache.UserName)"
            return $Script:AuthorizationO365Cache
        } else {
            $Credential   = $Script:AuthorizationO365Cache.Credential
            $Tenant       = $Script:AuthorizationO365Cache.Tenant
            $Subscription = $Script:AuthorizationO365Cache.Subscription
            $RefreshToken = $Script:AuthorizationO365Cache.RefreshToken
        }
    }

    if ($DomainName) {
        Write-Verbose -Message "Connect-O365Admin - Querying tenant to get domain name"
        $Tenant = Get-O365TenantID -DomainName $DomainName
    }

    $Tenant = if ($Tenant) { $Tenant } else { 'organizations' }
    $ScopesO365  = 'https://admin.microsoft.com/.default offline_access'
    $ScopesAzure = 'https://management.azure.com/.default offline_access'
    $ScopesGraph = 'https://graph.microsoft.com/.default offline_access'

    try {
        Write-Verbose -Message "Connect-O365Admin - Acquiring token for Graph"
        if ($RefreshToken -and -not $Credential -and -not $Device) {
            $tokenGraph = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesGraph -RefreshToken $RefreshToken
        } else {
            $tokenGraph = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesGraph -Credential $Credential -Device:$Device
        }
    } catch {
        Write-Warning -Message "Connect-O365Admin - Authentication failure for Graph. Error: $($_.Exception.Message)"
        return
    }
    $refresh = $tokenGraph.refresh_token
    try {
        Write-Verbose -Message "Connect-O365Admin - Acquiring token for admin.microsoft.com"
        $tokenO365 = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesO365 -RefreshToken $refresh
    } catch {
        Write-Warning -Message "Connect-O365Admin - Authentication failure for admin.microsoft.com. Error: $($_.Exception.Message)"
        return
    }
    try {
        Write-Verbose -Message "Connect-O365Admin - Acquiring token for Azure"
        $tokenAzure = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesAzure -RefreshToken $refresh
    } catch {
        Write-Warning -Message "Connect-O365Admin - Authentication failure for Azure. Error: $($_.Exception.Message)"
        return
    }

    if ($Credential) {
        $userName = $Credential.UserName
    } else {
        $jwt = if ($tokenGraph.id_token) { $tokenGraph.id_token } else { $tokenGraph.access_token }
        $tokenInfo = ConvertFrom-JSONWebToken -Token $jwt
        $userName = if ($tokenInfo.preferred_username) { $tokenInfo.preferred_username } else { $tokenInfo.upn }
    }

    $Script:AuthorizationO365Cache = [ordered] @{
        'Credential'     = $Credential
        'UserName'       = $userName
        'Environment'    = 'AzureCloud'
        'Subscription'   = $Subscription
        'Tenant'         = $Tenant
        'ExpiresOnUTC'   = ([datetime]::UtcNow).AddSeconds($ExpiresIn - $ExpiresTimeout)
        'RefreshToken'   = $refresh
        'AccessTokenO365' = $tokenO365.access_token
        'HeadersO365'     = [ordered] @{
            'Content-Type'           = 'application/json; charset=UTF-8'
            'Authorization'          = "Bearer $($tokenO365.access_token)"
            'X-Requested-With'       = 'XMLHttpRequest'
            'x-ms-client-request-id' = [guid]::NewGuid()
            'x-ms-correlation-id'    = [guid]::NewGuid()
        }
        'AccessTokenAzure' = $tokenAzure.access_token
        'HeadersAzure'     = [ordered] @{
            'Content-Type'           = 'application/json; charset=UTF-8'
            'Authorization'          = "Bearer $($tokenAzure.access_token)"
            'X-Requested-With'       = 'XMLHttpRequest'
            'x-ms-client-request-id' = [guid]::NewGuid()
            'x-ms-correlation-id'    = [guid]::NewGuid()
        }
        'AccessTokenGraph' = $tokenGraph.access_token
        'HeadersGraph'     = [ordered] @{
            'Content-Type'           = 'application/json; charset=UTF-8'
            'Authorization'          = "Bearer $($tokenGraph.access_token)"
            'X-Requested-With'       = 'XMLHttpRequest'
            'x-ms-client-request-id' = [guid]::NewGuid()
            'x-ms-correlation-id'    = [guid]::NewGuid()
        }
    }
    $Script:AuthorizationO365Cache
}
