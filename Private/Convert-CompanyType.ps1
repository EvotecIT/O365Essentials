function Convert-CompanyType {
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