function Set-O365PasswordResetIntegration {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $PasswordWritebackSupported,
        [nullable[bool]] $AccountUnlockEnabled
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/PasswordReset/OnPremisesPasswordResetPolicies"

    <#
    $Body = @{
        passwordWriteBackSupported = $passwordWriteBackSupported
        accountUnlockEnabled       = $AccountUnlockEnabled
        #accountUnlockSupported     = $accountUnlockSupported - doesn't seem to be used/work, always enabled
    }
    Remove-EmptyValue -Hashtable $Body
    if ($Body.Keys.Count -gt 0) {
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body
    }
    #>

    # It seems you need to set this separatly for AccountUnlockEnabled to be picked up properly.
    # So we do it..
    if ($null -ne $PasswordWritebackSupported) {
        $Body = @{
            passwordWriteBackSupported = $passwordWriteBackSupported
        }
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body
    }
    if ($null -ne $AccountUnlockEnabled) {
        $Body = @{
            accountUnlockEnabled = $AccountUnlockEnabled
        }
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT -Body $Body
    }
}