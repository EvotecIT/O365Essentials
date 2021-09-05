function Set-O365AzureEnterpriseAppsGroupConsent {
    # https://portal.azure.com/#blade/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/UserSettings
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][bool] $EnableGroupSpecificConsent,
        [Parameter()][string] $GroupId,
        [Parameter()][string] $GroupName
    )

    $Uri = 'https://graph.microsoft.com/beta/settings/e0953218-a490-4c92-a975-ab724a6cfb07'

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

    $CurrentSettings = Get-O365AzureEnterpriseAppsGroupConsent -Headers $Headers
    if ($CurrentSettings) {
        $Body = @{
            values = @(
                [ordered] @{ "name" = "EnableGroupSpecificConsent"; "value" = $EnableGroupSpecificConsent.ToString().ToLower() }
                [ordered] @{ "name" = "BlockUserConsentForRiskyApps"; "value" = $CurrentSettings.BlockUserConsentForRiskyApps.ToString().ToLower() }
                [ordered] @{ "name" = "EnableAdminConsentRequests"; "value" = $CurrentSettings.EnableAdminConsentRequests.ToString().ToLower() }
                [ordered] @{ "name" = "ConstrainGroupSpecificConsentToMembersOfGroupId"; value = $Group }
            )
        }
        $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PATCH -Body $Body
    }
}