function Connect-O365Admin {
    [cmdletbinding(DefaultParameterSetName = 'Credential')]
    param(
        [parameter(ParameterSetName = 'Credential')][PSCredential] $Credential,
        [parameter(ParameterSetName = 'Headers', DontShow)][alias('Authorization')][System.Collections.IDictionary] $Headers,
        [int] $ExpiresIn = 3600,
        [int] $ExpiresTimeout = 30,
        [switch] $ForceRefresh,
        [alias('TenantID')][string] $Tenant,
        [string] $DomainName,
        [string] $Subscription
    )

    if ($Headers) {
        if ($Headers.ExpiresOnUTC -gt [datetime]::UtcNow -and -not $ForceRefresh) {
            Write-Verbose -Message "Connect-O365Admin - Using cache for connection $($Headers.UserName)"
            return $Headers
        } else {
            # if header is expired, we need to use it's values to try and push it for refresh
            $Credential = $Headers.Credential
            $Tenant = $Headers.Tenant
            $Subscription = $Headers.Subscription
        }
    } elseif ($Script:AuthorizationO365Cache) {
        if ($Script:AuthorizationO365Cache.ExpiresOnUTC -gt [datetime]::UtcNow -and -not $ForceRefresh) {
            Write-Verbose -Message "Connect-O365Admin - Using cache for connection $($Script:AuthorizationO365Cache.UserName)"
            return $Script:AuthorizationO365Cache
        } else {
            $Credential = $Script:AuthorizationO365Cache.Credential
            $Tenant = $Script:AuthorizationO365Cache.Tenant
            $Subscription = $Script:AuthorizationO365Cache.Subscription
        }
    }

    if ($DomainName) {
        Write-Verbose -Message "Connect-O365Admin - Querying tenant to get domain name"
        $Tenant = Get-O365TenantID -DomainName $DomainName
    }

    try {
        $connectAzAccountSplat = @{
            Credential   = $Credential
            ErrorAction  = 'Stop'
            TenantId     = $Tenant
            Subscription = $Subscription
        }
        Remove-EmptyValue -Hashtable $connectAzAccountSplat
        Write-Verbose -Message "Connect-O365Admin - Connecting to Office 365 using Connect-AzAccount"
        $AzConnect = (Connect-AzAccount @connectAzAccountSplat -WarningVariable warningAzAccount -WarningAction SilentlyContinue )
    } catch {
        if ($_.CategoryInfo.Reason -eq 'AzPSAuthenticationFailedException') {
            if ($Credential) {
                Write-Warning -Message "Connect-O365Admin - Tenant most likely requires MFA. Please drop credential parameter, and just let the Connect-O365Admin prompt you for them."
            } else {
                Write-Warning -Message "Connect-O365Admin - Please provide DomainName or TenantID parameter."
            }
        } else {
            Write-Warning -Message "Connect-O365Admin - Error: $($_.Exception.Message)"
        }
        return
    }

    $Context = $AzConnect.Context

    try {
        Write-Verbose -Message "Connect-O365Admin - Establishing tokens for O365"
        $AuthenticationO365 = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate(
            $Context.Account,
            $Context.Environment,
            $Context.Tenant.Id.ToString(),
            $null,
            [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Auto,
            $null,
            'https://admin.microsoft.com'
        )

    } catch {
        Write-Warning -Message "Connect-O365Admin - Authentication failure. Error: $($_.Exception.Message)"
        return
    }
    try {
        Write-Verbose -Message "Connect-O365Admin - Establishing tokens for Azure"
        $AuthenticationAzure = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate(
            $Context.Account,
            $Context.Environment,
            $Context.Tenant.Id.ToString(),
            $null,
            [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Auto,
            $null,
            "74658136-14ec-4630-ad9b-26e160ff0fc6"
        )
    } catch {
        Write-Warning -Message "Connect-O365Admin - Authentication failure. Error: $($_.Exception.Message)"
        return
    }

    try {
        Write-Verbose -Message "Connect-O365Admin - Establishing tokens for Graph"
        $AuthenticationGraph = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate(
            $Context.Account,
            $Context.Environment,
            $Context.Tenant.Id.ToString(),
            $null,
            [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Auto,
            $null,
            "https://graph.microsoft.com"
        )
    } catch {
        Write-Warning -Message "Connect-O365Admin - Authentication failure. Error: $($_.Exception.Message)"
        return
    }

    Write-Verbose -Message "Connect-O365Admin - Disconnecting from O365 using Disconnect-AzAccount"
    $null = Disconnect-AzAccount -AzureContext $Context

    $Script:AuthorizationO365Cache = [ordered] @{
        'Credential'          = $Credential
        'UserName'            = $Context.Account
        'Environment'         = $Context.Environment
        'Subscription'        = $Subscription
        'Tenant'              = $Context.Tenant.Id
        'ExpiresOnUTC'        = ([datetime]::UtcNow).AddSeconds($ExpiresIn - $ExpiresTimeout)
        # This authorization is used for admin.microsoft.com
        'AuthenticationO365'  = $AuthenticationO365
        'AccessTokenO365'     = $AuthenticationO365.AccessToken
        'HeadersO365'         = [ordered] @{
            "Content-Type"           = "application/json; charset=UTF-8" ; 
            "Authorization"          = "Bearer $($AuthenticationO365.AccessToken)"
            'X-Requested-With'       = 'XMLHttpRequest'
            'x-ms-client-request-id' = [guid]::NewGuid()
            'x-ms-correlation-id'    = [guid]::NewGuid()
        }
        # This authorization is used for azure stuff
        'AuthenticationAzure' = $AuthenticationAzure
        'AccessTokenAzure'    = $AuthenticationAzure.AccessToken
        'HeadersAzure'        = [ordered] @{
            "Content-Type"           = "application/json; charset=UTF-8" ; 
            "Authorization"          = "Bearer $($AuthenticationAzure.AccessToken)"
            'X-Requested-With'       = 'XMLHttpRequest'
            'x-ms-client-request-id' = [guid]::NewGuid()
            'x-ms-correlation-id'    = [guid]::NewGuid()
        }
        'AuthenticationGraph' = $AuthenticationGraph
        'AccessTokenGraph'    = $AuthenticationGraph.AccessToken
        'HeadersGraph'        = [ordered] @{
            "Content-Type"           = "application/json; charset=UTF-8" ; 
            "Authorization"          = "Bearer $($AuthenticationGraph.AccessToken)"
            'X-Requested-With'       = 'XMLHttpRequest'
            'x-ms-client-request-id' = [guid]::NewGuid()
            'x-ms-correlation-id'    = [guid]::NewGuid()
        }
    }
    $Script:AuthorizationO365Cache
}