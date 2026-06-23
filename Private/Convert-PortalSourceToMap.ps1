function Convert-PortalSourceToMap {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)] $Source
    )

    $Parsed = [ordered] @{}
    if ($Source -is [System.Collections.IDictionary]) {
        foreach ($Key in $Source.Keys) {
            $Parsed[[string] $Key] = $Source[$Key]
        }
        return $Parsed
    }

    if ($Source.PSObject -and $Source.PSObject.Properties) {
        foreach ($Property in $Source.PSObject.Properties) {
            if ($Property.MemberType -notin 'NoteProperty', 'Property') {
                continue
            }
            $Parsed[$Property.Name] = $Property.Value
        }
    }
    $Parsed
}
