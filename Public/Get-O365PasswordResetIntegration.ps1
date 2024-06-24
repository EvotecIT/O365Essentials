function Get-O365PasswordResetIntegration {
    <#
        .SYNOPSIS
        Retrieves password reset integration details from the specified endpoint.
        .DESCRIPTION
        This function retrieves password reset integration details from the specified API endpoint using the provided headers.
        .PARAMETER Headers
        Authentication token and additional information for the API request.
    #>
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
