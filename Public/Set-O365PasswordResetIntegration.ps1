function Set-O365PasswordResetIntegration {
    <#
    .SYNOPSIS
    Configures password reset integration settings for Office 365.

    .DESCRIPTION
    This function updates the settings for password writeback and account unlock features in Office 365. 
    It allows enabling or disabling the password writeback and account unlock capabilities.

    .PARAMETER Headers
    Specifies the headers for the API request. Typically includes authorization tokens.

    .PARAMETER PasswordWritebackSupported
    Indicates whether password writeback is supported. Accepts $true or $false.

    .PARAMETER AccountUnlockEnabled
    Indicates whether account unlock is enabled. Accepts $true or $false.

    .EXAMPLE
    $headers = @{Authorization = "Bearer your_token"}
    Set-O365PasswordResetIntegration -Headers $headers -PasswordWritebackSupported $true -AccountUnlockEnabled $true
    
    This example enables both password writeback and account unlock features.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $PasswordWritebackSupported,
        [alias('AccountUnlockSupported')][nullable[bool]] $AllowUsersTounlockWithoutReset
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/PasswordReset/OnPremisesPasswordResetPolicies"

    # It seems you need to set this separatly for AccountUnlockEnabled to be picked up properly.
    # So we do it..
    if ($null -ne $PasswordWritebackSupported) {
        $Body = @{
            passwordWriteBackSupported = $passwordWriteBackSupported
        }
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body
    }
    if ($null -ne $AllowUsersTounlockWithoutReset) {
        $Body = @{
            accountUnlockEnabled = $AllowUsersTounlockWithoutReset
        }
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body
    }
}
