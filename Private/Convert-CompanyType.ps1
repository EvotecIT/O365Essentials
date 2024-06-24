function Convert-CompanyType {
    <#
    .SYNOPSIS
    Converts company type codes to their descriptive names.

    .DESCRIPTION
    This function takes an array of company type codes and converts each code to its corresponding descriptive name. 
    If a code does not have a corresponding name, the code itself is returned.

    .PARAMETER CompanyType
    An array of company type codes that need to be converted to descriptive names.

    .EXAMPLE
    Convert-CompanyType -CompanyType '5', '4'
    # Returns 'Indirect reseller', 'Reseller'
        
    .EXAMPLE
    Convert-CompanyType -CompanyType '5', '1'
    # Returns 'Indirect reseller', '1'
    # Note: '1' is returned as is because it does not have a corresponding name in the mapping.
        
    .NOTES
    Current mappings include:
    '5' for 'Indirect reseller'
    '4' for 'Reseller'
    #>
    [cmdletbinding()]
    param(
        [string[]] $CompanyType
    )
    $CompanyTypeInformation = [ordered] @{
        '5' = 'Indirect reseller'
        '4' = 'Reseller'
    }
    foreach ($Company in $CompanyType) {
        $CompanyName = $CompanyTypeInformation[$Company]
        if ($CompanyName) {
            $CompanyName
        } else {
            $Company
        }
    }
}
