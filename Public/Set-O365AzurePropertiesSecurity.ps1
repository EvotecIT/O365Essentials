function Set-O365AzurePropertiesSecurity {
    <#
    .SYNOPSIS
    Enables or disables Security Defaults for Azure AD.

    .DESCRIPTION
    This function updates the Security Defaults setting for Azure AD based on the provided parameter. Security Defaults is a set of security settings that are enabled by default to help protect your organization. If Classic policies are enabled, Security Defaults cannot be enabled.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER EnableSecurityDefaults
    Specifies whether to enable or disable Security Defaults. This parameter is mandatory.

    .EXAMPLE
    Set-O365AzurePropertiesSecurity -Headers $headers -EnableSecurityDefaults $true

    .NOTES
    For more information on Security Defaults, visit: https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/concept-fundamentals-security-defaults
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][bool] $EnableSecurityDefaults
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/SecurityDefaults/UpdateSecurityDefaultOnSave?enableSecurityDefaults=$EnableSecurityDefaults"

    $CurrentSettings = Get-O365AzurePropertiesSecurity -Headers $Headers
    if ($CurrentSettings.anyClassicPolicyEnabled -eq $false) {
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT
    } elseif ($CurrentSettings.anyClassicPolicyEnabled -eq $true) {
        Write-Warning -Message "Set-O365AzurePropertiesSecurity - It looks like you have Classic policies enabled. Enabling Classic policies prevents you from enabling Security defaults."
    }
}