function Connect-O365Admin {
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ParameterSetName = 'Credential')][PSCredential] $Credential,
        [int] $ExpiresIn = 3600,
        [int] $ExpiresTimeout = 30,
        [switch] $ForceRefresh
    )

    if (-not $Script:AuthorizationO365Cache) {
        $Script:AuthorizationO365Cache = [ordered] @{}
    }

    $UserName = $Credential.UserName

    if ($Script:AuthorizationO365Cache[$UserName] -and -not $ForceRefesh) {
        if ($Script:AuthorizationO365Cache[$UserName].ExpiresOnUTC -gt [datetime]::UtcNow) {
            Write-Verbose "Connect-O365Admin - Using cache for $UserName"
            return $Script:AuthorizationO365Cache[$UserName]
        }
    }

    $Script:AuthorizationO365Cache['CurrentUsername'] = $UserName

    $AzConnect = (Connect-AzAccount -Credential $Credential -ErrorAction Stop)

    $Context = $AzConnect.Context
    $Authentication = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate(
        $Context.Account,
        $Context.Environment,
        $Context.Tenant.Id.ToString(),
        $null,
        [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never,
        $null,
        "https://admin.microsoft.com"
    )

    $null = Disconnect-AzAccount -AzureContext $Context

    $Script:AuthorizationO365Cache[$UserName] = [ordered] @{
        'Credential'     = $Credential
        'UserName'       = $Context.Account
        'Environment'    = $Context.Environment
        'Tenant'         = $Context.Tenant.Id
        'Authentication' = $Authentication
        'AccessToken'    = $Authentication.AccessToken
        'ExpiresOnUTC'   = ([datetime]::UtcNow).AddSeconds($ExpiresIn - $ExpiresTimeout)
        'Headers'        = [ordered] @{ "Content-Type" = "application/json; charset=UTF-8" ; "Authorization" = "Bearer $($Authentication.AccessToken)" }

    }
    $Script:AuthorizationO365Cache[$UserName]
}