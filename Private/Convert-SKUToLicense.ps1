function Convert-SKUToLicense {
    [cmdletbinding()]
    param(
        [parameter()][string] $SKU
    )

    $ServicePlans = Get-O365AzureLicenses -LicenseSKUID $SKU -ServicePlans -IncludeLicenseDetails
    if ($ServicePlans) {
        $ServicePlans
    }
}