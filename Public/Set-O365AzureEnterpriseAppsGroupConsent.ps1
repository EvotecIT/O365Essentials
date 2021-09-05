function Set-O365AzureEnterpriseAppsGroupConsent {
    # https://portal.azure.com/#blade/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/UserSettings
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter()][bool] $EnableGroupSpecificConsent,
        [Parameter()][string] $GroupId,
        [Parameter()][string] $GroupName,
        # Other options
        [Parameter()][bool] $BlockUserConsentForRiskyApps,
        [Parameter()][bool] $EnableAdminConsentRequests
    )

    $Uri = 'https://graph.microsoft.com/beta/settings/e0953218-a490-4c92-a975-ab724a6cfb07'
    $CurrentSettings = Get-O365AzureEnterpriseAppsGroupConsent -Headers $Headers
    if ($CurrentSettings) {
        [string] $EnableSpecific = if ($PSBoundParameters.ContainsKey('EnableGroupSpecificConsent')) {
            $EnableGroupSpecificConsent.ToString().ToLower()
        } else {
            $CurrentSettings.EnableGroupSpecificConsent.ToString().ToLower()
        }
        if ($PSBoundParameters.ContainsKey('EnableGroupSpecificConsent')) {
            # We only set group if EnableGroupSpecificConsent is used
            if ($GroupId) {
                $Group = $GroupId
            } elseif ($GroupName) {
                $AskForGroup = Get-O365Group -DisplayName $GroupName -Headers $Headers
                if ($AskForGroup.Id) {
                    $Group = $AskForGroup.Id
                    if ($Group -isnot [string]) {
                        Write-Warning -Message "Set-O365AzureEnterpriseAppsGroupConsent - GroupName couldn't be translated to single ID. "
                        foreach ($G in $AskForGroup) {
                            Write-Warning -Message "Group DisplayName: $($G.DisplayName) | Group ID: $($G.ID)"
                        }
                        return
                    }
                } else {
                    Write-Warning -Message "Set-O365AzureEnterpriseAppsGroupConsent - GroupName couldn't be translated to ID. Skipping."
                    return
                }
            } else {
                $Group = ''
            }
        } else {
            # We read the current group
            $Group = $CurrentSettings.ConstrainGroupSpecificConsentToMembersOfGroupId
        }
        [string] $BlockUserConsent = if ($PSBoundParameters.ContainsKey('BlockUserConsentForRiskyApps')) {
            $BlockUserConsentForRiskyApps.ToString().ToLower()
        } else {
            $CurrentSettings.BlockUserConsentForRiskyApps.ToString().ToLower()
        }
        [string] $AdminConsent = if ($PSBoundParameters.ContainsKey('EnableAdminConsentRequests')) {
            $EnableAdminConsentRequests.ToString().ToLower()
        } else {
            $CurrentSettings.EnableAdminConsentRequests.ToString().ToLower()
        }
        $Body = @{
            values = @(
                [ordered] @{ "name" = "EnableGroupSpecificConsent"; "value" = $EnableSpecific }
                [ordered] @{ "name" = "BlockUserConsentForRiskyApps"; "value" = $BlockUserConsent }
                [ordered] @{ "name" = "EnableAdminConsentRequests"; "value" = $AdminConsent }
                [ordered] @{ "name" = "ConstrainGroupSpecificConsentToMembersOfGroupId"; value = $Group }
            )
        }
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PATCH -Body $Body
    }
}