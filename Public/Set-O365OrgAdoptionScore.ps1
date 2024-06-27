function Set-O365OrgAdoptionScore {
    <#
    .SYNOPSIS
    Configures the organization's adoption score settings for Office 365.

    .DESCRIPTION
    This function allows setting various configurations related to the organization's adoption score in Office 365. It enables or disables insights, sets group-level insights, and allows approved admins to send recommendations.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER EnableInsights
    Specifies whether to enable insights for the organization.

    .PARAMETER LimitGroupId
    An array of group IDs to limit the insights for.

    .PARAMETER LimitGroupName
    An array of group names to limit the insights for.

    .PARAMETER TurnOnGroupLevelInsights
    Enables or disables group-level insights.

    .PARAMETER AllowApprovedAdminsToSendRecommendations
    Specifies whether approved admins are allowed to send recommendations.

    .EXAMPLE
    Set-O365OrgAdoptionScore -Headers $headers -EnableInsights $true -TurnOnGroupLevelInsights $true -AllowApprovedAdminsToSendRecommendations $true

    .NOTES
    This function is used to manage the organization's adoption score settings, including enabling insights, setting group-level insights, and allowing approved admins to send recommendations.
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [Parameter(Mandatory)][bool] $EnableInsights,
        [Array] $LimitGroupId,
        [Array] $LimitGroupName,
        [Parameter(Mandatory)][bool] $TurnOnGroupLevelInsights,
        [Parameter(Mandatory)][bool] $AllowApprovedAdminsToSendRecommendations
    )
    $Uri = "https://admin.microsoft.com/admin/api/reports/productivityScoreCustomerOption"

    $Body = @{
        ProductivityScoreOptedIn = $EnableInsights
        PSGroupsOptedOut         = $false
        CohortInsightOptedIn     = $false
        ActionFlowOptedIn        = $false
        PSOptedOutGroupIds       = $null
    }
    if ($PSBoundParameters.ContainsKey('CohortInsightOptedIn')) {
        $Body['CohortInsightOptedIn'] = $TurnOnGroupLevelInsights
    }
    if ($PSBoundParameters.ContainsKey('AllowApprovedAdminsToSendRecommendations')) {
        $Body['ActionFlowOptedIn'] = $AllowApprovedAdminsToSendRecommendations
    }

    if ($LimitGroupId.Count -gt 0 -or $LimitGroupName.Count -gt 0) {
        $Body['PSGroupsOptedOut'] = $true
        [Array] $Groups = @(
            foreach ($Group in $LimitGroupID) {
                $GroupInformation = Get-O365Group -Id $Group -Headers $Headers
                if ($GroupInformation.id) {
                    $GroupInformation
                }
            }
            foreach ($Group in $LimitGroupName) {
                $GroupInformation = Get-O365Group -DisplayName $Group -Headers $Headers
                if ($GroupInformation.id) {
                    $GroupInformation
                }
            }
        )
        $Body['PSOptedOutGroupIds'] = @(
            foreach ($Group in $Groups) {
                $Group.id
            }
        )
    }

    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
}