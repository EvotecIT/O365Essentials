function New-HealthLeafBundle {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][System.Collections.IEnumerable] $Leaves
    )

    $Bundle = [ordered] @{}
    $TimingMap = @{}

    foreach ($Leaf in @($Leaves)) {
        $Bundle[$Leaf.Name] = $Leaf.Value
        $TimingMap[$Leaf.Name] = $Leaf
    }

    $Bundle['__O365ComponentTimings'] = $TimingMap
    [PSCustomObject] $Bundle
}
