function Set-O365AzurePropertiesSecurity {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][bool] $EnableSecurityDefaults
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/SecurityDefaults/UpdateSecurityDefaultOnSave?enableSecurityDefaults=$EnableSecurityDefaults"

    $CurrentSettings = Get-O365AzurePropertiesSecurity -Headers $Headers
    if ($CurrentSettings.anyClassicPolicyEnabled -eq $false) {
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PUT
    } elseif ($CurrentSettings.anyClassicPolicyEnabled -eq $true) {
        Write-Warning -Message "Set-O365AzurePropertiesSecurity - It looks like you have Classic policies enabled. Enabling Classic policies prevents you from enabling Security defaults."
    }
}