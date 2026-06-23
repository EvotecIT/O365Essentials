function Get-MappedPortalValue {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)] $Source,
        [Parameter(Mandatory)][string[]] $Names
    )

    foreach ($Name in $Names) {
        if ($Source -is [System.Collections.IDictionary]) {
            if ($Source.Contains($Name)) {
                return $Source[$Name]
            }
        }
        elseif ($Source.PSObject -and $Source.PSObject.Properties[$Name]) {
            return $Source.PSObject.Properties[$Name].Value
        }
    }
}
