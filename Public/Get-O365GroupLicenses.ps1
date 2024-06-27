function Get-O365GroupLicenses {
    <#
    .SYNOPSIS
    Retrieves the licenses information for a specified Office 365 group.

    .DESCRIPTION
    This function retrieves the licenses information for an Office 365 group based on the provided GroupID or GroupDisplayName. It can also include detailed service plans information if specified.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER GroupID
    The ID of the group to query.

    .PARAMETER GroupDisplayName
    The display name of the group to query.

    .PARAMETER ServicePlans
    Switch parameter to indicate whether to retrieve detailed service plans information.

    .PARAMETER NoTranslation
    Switch parameter to skip translation of the output.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter()][string] $GroupID,
        [parameter()][alias('GroupName')][string] $GroupDisplayName,
        [switch] $ServicePlans,
        [switch] $NoTranslation
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
        $Uri = "https://main.iam.ad.ext.azure.com/api/AccountSkus/Group/$Group"
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
        if ($Output) {
            if ($NoTranslation) {
                $Output
            } else {
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
}
