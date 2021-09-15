function Set-O365SearchIntelligenceItemInsights {
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [bool] $AllowItemInsights,
        [string] $DisableGroupName,
        [string] $DisableGroupID
    )
    $Uri = "https://admin.microsoft.com/fd/configgraphprivacy/ceb371f6-8745-4876-a040-69f2d10a9d1a/settings/ItemInsights"

    if ($PSBoundParameters.ContainsKey('AllowItemInsights')) {
        if ($DisableGroupID) {
            $GroupInformation = Get-O365Group -Id $DisableGroupID -Headers $Headers
        } elseif ($DisableGroupName) {
            $GroupInformation = Get-O365Group -DisplayName $DisableGroupName -Headers $Headers
        }
        if ($GroupInformation.id) {
            $DisabledForGroup = $GroupInformation.id
        } else {
            $DisabledForGroup = $null
        }
        $Body = @{
            isEnabledInOrganization = $AllowItemInsights
            disabledForGroup        = $DisabledForGroup
        }
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method PATCH -Body $Body
        $Output
    }
}