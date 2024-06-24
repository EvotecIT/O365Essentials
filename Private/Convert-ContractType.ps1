function Convert-ContractType {
    <#
        .SYNOPSIS
        Converts contract type codes to their descriptive names.

        .DESCRIPTION
        This function takes an array of contract type codes and converts each code to its corresponding descriptive name.
        If a code does not have a corresponding name, the code itself is returned.
        
        .PARAMETER ContractType
        An array of contract type codes that need to be converted to descriptive names.
        
        .EXAMPLE
        Convert-ContractType -ContractType '3', '1'
        # Returns 'Reseller', '1'
        # Note: '1' is returned as is because it does not have a corresponding name in the mapping.
        
        .NOTES
        Current mappings include:
        '3' for 'Reseller'
    #>
    [cmdletbinding()]
    param(
        [string[]] $ContractType
    )
    $ContractTypeInformation = [ordered] @{
        '3' = 'Reseller'
    }
    foreach ($Contract in $ContractType) {
        $ContractName = $ContractTypeInformation[$Contract]
        if ($ContractName) {
            $ContractName
        } else {
            $Contract
        }
    }
}
