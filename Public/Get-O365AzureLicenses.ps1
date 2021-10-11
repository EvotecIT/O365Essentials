function Get-O365AzureLicenses {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

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

    .EXAMPLE
    $ServicePlans = Get-O365AzureLicenses -ServicePlans -LicenseSKUID 'evotecpoland:EMSPREMIUM' -IncludeLicenseDetails -Verbose
    $ServicePlans | Format-Table

    .NOTES
    General notes
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [string] $LicenseName,
        [switch] $ServicePlans,
        [switch] $ServicePlansComplete,
        [string] $LicenseSKUID,
        [switch] $IncludeLicenseDetails
    )

    # Maybe change it to https://docs.microsoft.com/en-us/graph/api/subscribedsku-list?view=graph-rest-1.0&tabs=http
    # Or maybe not because it doesn't contain exactly same data missing displayName from service plans
    # $Uri = "https://graph.microsoft.com/v1.0/subscribedSkus"

    $Uri = "https://main.iam.ad.ext.azure.com/api/AccountSkus"

    $QueryParameter = @{
        backfillTenants = $false
    }

    if (-not $Script:AzureLicensesList) {
        Write-Verbose -Message "Get-O365AzureLicenses - Querying for Licenses SKU"
        $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter
        # We build a list of all the licenses, for caching purposes
        if ($Output) {
            $Script:AzureLicensesList = $Output
        }
    } else {
        Write-Verbose -Message "Get-O365AzureLicenses - Reusing cache for Licenses SKU"
        $Output = $Script:AzureLicensesList
    }

    # If license name or license id is provided we filter thjings out
    if ($LicenseName) {
        $Output = $Output | Where-Object { $_.Name -eq $LicenseName }
    } elseif ($LicenseSKUID) {
        $Output = $Output | Where-Object {
            $TempSplit = $_.AccountSkuId -split ':'
            $TempSplit[1] -eq $LicenseSKUID -or $_.AccountSkuId -eq $LicenseSKUID
        }
    }

    # we then based on ServicePlans request only display service plans
    if ($ServicePlans) {
        foreach ($O in $Output) {
            if ($IncludeLicenseDetails) {
                foreach ($Plan in $O.serviceStatuses.servicePlan) {
                    [PSCustomObject] @{
                        LicenseName        = $O.Name
                        LicenseSKUID       = $O.AccountSkuId
                        ServiceDisplayName = $Plan.displayName
                        ServiceName        = $Plan.serviceName
                        ServicePlanId      = $Plan.servicePlanId
                        ServiceType        = $Plan.serviceType
                    }
                }
            } else {
                $O.serviceStatuses.servicePlan
            }
        }
    } elseif ($ServicePlansComplete) {
        # or display everything
        foreach ($O in $Output) {
            [PSCustomObject] @{
                Name           = $O.Name
                AccountSkuID   = $O.AccountSkuId
                ServicePlan    = $O.serviceStatuses.servicePlan
                AvailableUnits = $o.availableUnits
                TotalUnits     = $O.totalUnits
                ConsumedUnits  = $O.consumedUnits
                WarningUnits   = $O.warningUnits
            }
        }
    } else {
        $Output
    }
}


# https://main.iam.ad.ext.azure.com/api/AccountSkus/UserAssignments?accountSkuID=evotecpoland%3AEMSPREMIUM&nextLink=&searchText=&columnName=&sortOrder=undefined
# https://main.iam.ad.ext.azure.com/api/AccountSkus/UserAssignments?accountSkuID=evotecpoland%3AEMSPREMIUM&nextLink=&searchText=&columnName=&sortOrder=undefined
# https://main.iam.ad.ext.azure.com/api/AccountSkus/GroupAssignments?accountSkuID=evotecpoland%3AEMSPREMIUM&nextLink=&searchText=&sortOrder=undefined