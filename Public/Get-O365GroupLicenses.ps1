function Get-O365GroupLicenses {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter()][string] $GroupID,
        [parameter()][alias('GroupName')][string] $GroupDisplayName,
        [switch] $ServicePlans
    )

    if ($GroupID) {
        $Group = $GroupID
    } elseif ($GroupDisplayName) {
        $GroupSearch = Get-O365Group -DisplayName $GroupDisplayName
        if ($GroupSearch.id) {
            $Group = $GroupSearch.id
        }
    }
    if ($Group) {
        $Uri = "https://main.iam.ad.ext.azure.com/api/AccountSkus/Group/$Group"
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
        if ($Output) {
            foreach ($License in $Output.licenses) {
                $SP = Convert-SKUToLicense -SKU $License.accountSkuID
                if ($SP) {
                    $ServicePlansPrepared = Find-EnabledServicePlan -ServicePlans $SP -DisabledServicePlans $License.disabledServicePlans
                    [PSCustomObject] @{
                        License      = $SP[0].LicenseName
                        LicenseSKUID = $SP[0].LicenseSKUID
                        Enabled      = $ServicePlansPrepared.Enabled.ServiceDisplayName
                        Disabled     = $ServicePlansPrepared.Disabled.ServiceDisplayName
                        EnabledPlan  = $ServicePlansPrepared.Enabled
                        DisabledPlan = $ServicePlansPrepared.Disabled
                    }
                }
            }
        }
    }
}