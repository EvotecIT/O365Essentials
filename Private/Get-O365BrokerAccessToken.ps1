function Get-O365BrokerAccessToken {
    <#
    .SYNOPSIS
    Gets a delegated access token through the bundled MSAL WAM broker helper.
    #>
    [cmdletbinding(DefaultParameterSetName = 'Resource')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Resource')][string] $ResourceUrl,
        [Parameter(Mandatory, ParameterSetName = 'Scope')][string] $Scope,
        [string] $Tenant = 'organizations',
        [string] $ClientId,
        [string] $Account,
        [switch] $ForcePrompt
    )

    if ([string]::IsNullOrWhiteSpace($ClientId)) {
        $ClientId = if ($PSCmdlet.ParameterSetName -eq 'Scope') {
            # Microsoft Graph PowerShell public client. Its broker redirect URI is WAM-capable for delegated Graph scopes.
            '14d82eec-204b-4c2f-b7e8-296a70dab67e'
        } else {
            # Azure PowerShell public client works with the Microsoft 365 admin, portal, Teams, and ARM resource audiences.
            '1950a258-227b-4e31-a9cf-717495945fc2'
        }
    }

    if ($PSEdition -ne 'Core' -or $PSVersionTable.PSVersion -lt [version] '7.4') {
        throw 'MSAL WAM broker authentication requires PowerShell 7.4 or newer.'
    }

    $BrokerClientType = 'O365Essentials.Auth.BrokerTokenClient' -as [type]
    if (-not $BrokerClientType) {
        throw 'The O365Essentials MSAL WAM helper is not loaded. Build or import the packaged module so O365Essentials.Auth.dll is loaded through the module AssemblyLoadContext.'
    }

    try {
        if ($PSCmdlet.ParameterSetName -eq 'Scope') {
            $Result = $BrokerClientType.GetMethod('AcquireTokenForScope').Invoke($null, @($Tenant, $Scope, $ClientId, $Account, [bool] $ForcePrompt))
        } else {
            $Result = $BrokerClientType.GetMethod('AcquireTokenForResource').Invoke($null, @($Tenant, $ResourceUrl, $ClientId, $Account, [bool] $ForcePrompt))
        }
    } catch [System.Reflection.TargetInvocationException] {
        $Inner = $_.Exception.InnerException
        if ($Inner) {
            throw "MSAL WAM token acquisition failed. $($Inner.Message)"
        }
        throw
    } catch {
        throw "MSAL WAM token acquisition failed. $($_.Exception.Message)"
    }

    $ExpiresOnUtc = $null
    if ($Result.ExpiresOn -is [datetimeoffset]) {
        $ExpiresOnUtc = $Result.ExpiresOn.UtcDateTime
    } elseif ($Result.ExpiresOn -is [datetime]) {
        $ExpiresOnUtc = $Result.ExpiresOn.ToUniversalTime()
    }

    [PSCustomObject] @{
        access_token = $Result.AccessToken
        expires_on   = $ExpiresOnUtc
        tenant_id    = $Result.TenantId
        account      = $Result.AccountUsername
        scopes       = $Result.Scopes
    }
}
