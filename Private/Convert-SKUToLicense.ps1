function Convert-SKUToLicense {
    <#
        .SYNOPSIS
        Converts a SKU to its corresponding license details.

        .DESCRIPTION
        This function takes a SKU (Stock Keeping Unit) identifier and retrieves the associated service plans and license details.
        
        .PARAMETER SKU
        The SKU identifier for which the license details need to be retrieved.
        
        .EXAMPLE
        Convert-SKUToLicense -SKU "ENTERPRISEPACK"
        # Returns the service plans and license details for the specified SKU.
        
        .NOTES
        This function relies on the Get-O365AzureLicenses cmdlet to fetch the license details.
    #>
    [cmdletbinding()]
    param(
        [parameter()][string] $SKU
    )

    $ServicePlans = Get-O365AzureLicenses -LicenseSKUID $SKU -ServicePlans -IncludeLicenseDetails
    if ($ServicePlans) {
        $ServicePlans
    }
}
