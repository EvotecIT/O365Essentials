function New-SearchFallbackResult {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)] $Result,
        [Parameter(Mandatory)][string] $RequestedName,
        [Parameter(Mandatory)][string] $FallbackName
    )

    if ($Result -is [psobject] -and $Result -isnot [string] -and $Result -isnot [ValueType]) {
        $FallbackResult = $Result | Select-Object *
        $FallbackResult | Add-Member -NotePropertyName RequestedName -NotePropertyValue $RequestedName -Force
        $FallbackResult | Add-Member -NotePropertyName FallbackName -NotePropertyValue $FallbackName -Force
        $FallbackResult | Add-Member -NotePropertyName FallbackUsed -NotePropertyValue $true -Force
        $FallbackResult | Add-Member -NotePropertyName FallbackDescription -NotePropertyValue 'The Configurations endpoint did not return usable data, so ConfigurationSettings was returned instead.' -Force
        return $FallbackResult
    }

    [pscustomobject]@{
        RequestedName       = $RequestedName
        FallbackName        = $FallbackName
        FallbackUsed        = $true
        FallbackDescription = 'The Configurations endpoint did not return usable data, so ConfigurationSettings was returned instead.'
        Result              = $Result
    }
}
