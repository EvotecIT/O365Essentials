function Connect-O365Admin {
    [cmdletbinding(DefaultParameterSetName = 'Credential')]
    param(
        [parameter(ParameterSetName = 'Credential')][PSCredential] $Credential,
        [parameter(ParameterSetName = 'Headers', DontShow)][alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(ParameterSetName = 'App')][string] $ClientId,
        [parameter(ParameterSetName = 'App')][string] $ClientSecret,
        [parameter(ParameterSetName = 'App')] $Certificate,
        [int] $ExpiresIn = 3600,
        [int] $ExpiresTimeout = 30,
        [switch] $ForceRefresh,
        [switch] $Device,
        # Tenant ID; defaults to 'organizations' and is replaced with the actual tenant after sign-in
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
            $Credential = $Headers.Credential
            $ClientId = $Headers.ClientId
            $ClientSecret = $Headers.ClientSecret
            $Certificate = $Headers.Certificate
            $Tenant = $Headers.Tenant
            $Subscription = $Headers.Subscription
            $RefreshToken = $Headers.RefreshToken
        }
    } elseif ($Script:AuthorizationO365Cache) {
        if ($Script:AuthorizationO365Cache.ExpiresOnUTC -gt [datetime]::UtcNow -and -not $ForceRefresh) {
            Write-Verbose -Message "Connect-O365Admin - Using cache for connection $($Script:AuthorizationO365Cache.UserName)"
            return $Script:AuthorizationO365Cache
        } else {
            $Credential = $Script:AuthorizationO365Cache.Credential
            $ClientId = $Script:AuthorizationO365Cache.ClientId
            $ClientSecret = $Script:AuthorizationO365Cache.ClientSecret
            $Certificate = $Script:AuthorizationO365Cache.Certificate
            $Tenant = $Script:AuthorizationO365Cache.Tenant
            $Subscription = $Script:AuthorizationO365Cache.Subscription
            $RefreshToken = $Script:AuthorizationO365Cache.RefreshToken
        }
    }

    if ($DomainName) {
        Write-Verbose -Message "Connect-O365Admin - Querying tenant to get domain name"
        $Tenant = Get-O365TenantID -DomainName $DomainName
    }

    $Tenant = if ($Tenant) { $Tenant } else { 'organizations' }
    $ScopesO365 = 'https://admin.microsoft.com/.default offline_access'
    $ScopesAzure = '74658136-14ec-4630-ad9b-26e160ff0fc6/.default offline_access'
    $ScopesGraph = 'https://graph.microsoft.com/.default offline_access'

    try {
        Write-Verbose -Message "Connect-O365Admin - Acquiring token for Graph"
        if ($PSCmdlet.ParameterSetName -eq 'App') {
            $tokenGraph = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesGraph -ClientId $ClientId -ClientSecret $ClientSecret -Certificate $Certificate
        } elseif ($RefreshToken -and -not $Credential -and -not $Device) {
            $tokenGraph = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesGraph -RefreshToken $RefreshToken
        } else {
            $tokenGraph = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesGraph -Credential $Credential -Device:$Device
        }
    } catch {
        Write-Warning -Message "Connect-O365Admin - Authentication failure for Graph. Error: $($_.Exception.Message)"
        return
    }

    # Read tenant information from the token so subsequent requests use the correct tenant
    $jwtTenant = if ($tokenGraph.id_token) { $tokenGraph.id_token } else { $tokenGraph.access_token }
    $tenantInfo = ConvertFrom-JSONWebToken -Token $jwtTenant
    if (-not $PSBoundParameters.ContainsKey('Tenant') -or $Tenant -eq 'organizations') {
        $Tenant = $tenantInfo.tid
    }
    $refresh = $tokenGraph.refresh_token
    try {
        Write-Verbose -Message "Connect-O365Admin - Acquiring token for admin.microsoft.com"
        if ($PSCmdlet.ParameterSetName -eq 'App') {
            $tokenO365 = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesO365 -ClientId $ClientId -ClientSecret $ClientSecret -Certificate $Certificate
        } else {
            $tokenO365 = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesO365 -RefreshToken $refresh
        }
    } catch {
        Write-Warning -Message "Connect-O365Admin - Authentication failure for admin.microsoft.com. Error: $($_.Exception.Message)"
        return
    }
    try {
        Write-Verbose -Message "Connect-O365Admin - Acquiring token for Azure"
        if ($PSCmdlet.ParameterSetName -eq 'App') {
            $tokenAzure = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesAzure -ClientId $ClientId -ClientSecret $ClientSecret -Certificate $Certificate
        } else {
            $tokenAzure = Get-O365OAuthToken -Tenant $Tenant -Scope $ScopesAzure -RefreshToken $refresh
        }
    } catch {
        Write-Warning -Message "Connect-O365Admin - Authentication failure for Azure. Error: $($_.Exception.Message)"
        return
    }

    if ($PSCmdlet.ParameterSetName -eq 'App') {
        $userName = $ClientId
    } elseif ($Credential) {
        $userName = $Credential.UserName
    } else {
        $jwt = if ($tokenGraph.id_token) { $tokenGraph.id_token } else { $tokenGraph.access_token }
        $tokenInfo = ConvertFrom-JSONWebToken -Token $jwt
        $userName = if ($tokenInfo.preferred_username) { $tokenInfo.preferred_username } else { $tokenInfo.upn }
    }

    $Script:AuthorizationO365Cache = [ordered] @{
        'Credential'       = $Credential
        'ClientId'         = $ClientId
        'ClientSecret'     = $ClientSecret
        'Certificate'      = $Certificate
        'UserName'         = $userName
        'Environment'      = 'AzureCloud'
        'Subscription'     = $Subscription
        'Tenant'           = $Tenant
        'ExpiresOnUTC'     = ([datetime]::UtcNow).AddSeconds($ExpiresIn - $ExpiresTimeout)
        'RefreshToken'     = $refresh
        'AccessTokenO365'  = $tokenO365.access_token
        'HeadersO365'      = [ordered] @{
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
