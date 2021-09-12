function Set-O365PasswordResetIntegration {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $PasswordWritebackSupported,
        [alias('AccountUnlockSupported')][nullable[bool]] $AllowUsersTounlockWithoutReset
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/PasswordReset/OnPremisesPasswordResetPolicies"

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