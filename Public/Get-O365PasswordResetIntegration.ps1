function Get-O365PasswordResetIntegration {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    #$Uri = "https://main.iam.ad.ext.azure.com/api/PasswordReset/IsOnPremisesPasswordResetAvailable"
    $Uri = "https://main.iam.ad.ext.azure.com/api/PasswordReset/OnPremisesPasswordResetPolicies"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        [PSCustomObject] @{
            PasswordWritebackSupported = $Output.passwordWritebackSupported
            # This one doesn't change and stays enabled all the time
            #AccountUnlockSupported     = $Output.accountUnlockSupported
            AccountUnlockEnabled       = $Output.accountUnlockEnabled
        }
    }
}