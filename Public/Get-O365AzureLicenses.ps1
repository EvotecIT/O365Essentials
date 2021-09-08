function Get-O365AzureLicenses {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Headers
    Parameter description

    .PARAMETER LicenseName
    Parameter description

    .PARAMETER ServicePlans
    Parameter description

    .PARAMETER LicenseSKUID
    Parameter description

    .EXAMPLE
    $Licenses = Get-O365AzureLicenses
    $Licenses | Format-Table

    .EXAMPLE
    $ServicePlans = Get-O365AzureLicenses -ServicePlans -LicenseName 'Enterprise Mobility + Security E5' -Verbose
    $ServicePlans | Format-Table

    .EXAMPLE
    $ServicePlans = Get-O365AzureLicenses -ServicePlans -LicenseSKUID 'EMSPREMIUM' -Verbose
    $ServicePlans | Format-Table

    .EXAMPLE
    $ServicePlans = Get-O365AzureLicenses -ServicePlans -LicenseSKUID 'evotecpoland:EMSPREMIUM' -Verbose
    $ServicePlans | Format-Table

    .NOTES
    General notes
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [string] $LicenseName,
        [switch] $ServicePlans,
        [string] $LicenseSKUID
    )

    $Uri = "https://main.iam.ad.ext.azure.com/api/AccountSkus"

    $QueryParameter = @{
        backfillTenants = $false
    }

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter
    if ($LicenseName) {
        $Output = $Output | Where-Object { $_.Name -eq $LicenseName }
    } elseif ($LicenseSKUID) {
        $Output = $Output | Where-Object {
            $TempSplit = $_.AccountSkuId -split ':'
            $TempSplit[1].AccountSkuId -eq $LicenseSKUID -or $_.AccountSkuId -eq $LicenseSKUID
        }
    }
    if ($LicenseName -and $ServicePlans) {
        foreach ($O in $Output) {
            $O.serviceStatuses.servicePlan
        }
    } elseif ($LicenseSKUID -and $ServicePlans) {
        foreach ($O in $Output) {
            $O.serviceStatuses.servicePlan
        }
    } elseif ($ServicePlans) {
        foreach ($O in $Output) {
            [PSCustomObject] @{
                Name           = $O.Name
                AccountSkuID   = $O.AccountSkuId
                ServicePlan    = $O.serviceStatuses.servicePlan
                availableUnits = $o.availableUnits
                totalUnits     = $O.totalUnits
                consumedUnits  = $O.consumedUnits
                warningUnits   = $O.warningUnits
            }
        }
    } else {
        $Output
    }
}


# https://main.iam.ad.ext.azure.com/api/AccountSkus/UserAssignments?accountSkuID=evotecpoland%3AEMSPREMIUM&nextLink=&searchText=&columnName=&sortOrder=undefined
# https://main.iam.ad.ext.azure.com/api/AccountSkus/UserAssignments?accountSkuID=evotecpoland%3AEMSPREMIUM&nextLink=&searchText=&columnName=&sortOrder=undefined
# https://main.iam.ad.ext.azure.com/api/AccountSkus/GroupAssignments?accountSkuID=evotecpoland%3AEMSPREMIUM&nextLink=&searchText=&sortOrder=undefined
