function Set-O365AzureEnterpriseAppsGroupConsent {
    <#
    .SYNOPSIS
    Provides functionality to set group-specific consent for enterprise apps in Azure Active Directory.

    .DESCRIPTION
    This function allows administrators to configure group-specific consent for enterprise apps in Azure Active Directory.

    .PARAMETER Headers
    Specifies the headers for the API request, typically including authorization tokens.

    .PARAMETER EnableGroupSpecificConsent
    Specifies whether to enable group-specific consent.

    .PARAMETER GroupId
    The ID of the group for which to set consent.

    .PARAMETER GroupName
    The display name of the group for which to set consent.

    .PARAMETER BlockUserConsentForRiskyApps
    Specifies whether to block user consent for risky apps.

    .PARAMETER EnableAdminConsentRequests
    Specifies whether to enable admin consent requests.

    .EXAMPLE
    An example of how to use this function:
    Set-O365AzureEnterpriseAppsGroupConsent -Headers $headers -EnableGroupSpecificConsent $true -GroupId "12345" -BlockUserConsentForRiskyApps $true -EnableAdminConsentRequests $false

    .NOTES
    Please ensure that:
    - Group-specific consent can be set using either GroupId or GroupName parameter.
    #>
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
