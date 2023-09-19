function Set-O365OrgAdoptionScore {
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