function Convert-ContractType {
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