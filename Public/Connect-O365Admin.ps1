function Connect-O365Admin {
    [cmdletbinding()]
    param(
        [parameter(Mandatory, ParameterSetName = 'Credential')][PSCredential] $Credential,
        [switch] $ForceRefresh
    )
    # define cache
    if (-not $Script:AuthorizationO365Cache) {
        $Script:AuthorizationO365Cache = [ordered] @{}
    }

    if ($Script:AuthorizationO365Cache['AccessToken'] -and -not $ForceRefesh) {
        Write-Verbose "Connect-O365Admin - Using cache for '....'"
        return $Script:AuthorizationO365Cache
    }

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

    $Script:AuthorizationO365Cache['Authentication'] = $Authentication
    $Script:AuthorizationO365Cache['AccessToken'] = $Authentication.AccessToken
    $Script:AuthorizationO365Cache['Headers'] = @{ "Content-Type" = "application/json; charset=UTF-8" ; "Authorization" = "Bearer $($Authentication.AccessToken)" }
    $Script:AuthorizationO365Cache
}