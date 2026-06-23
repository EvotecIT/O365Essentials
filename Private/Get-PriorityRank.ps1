function Get-PriorityRank {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $Priority
    )

    switch ($Priority) {
        'High' { 0 }
        'Medium' { 1 }
        'Low' { 2 }
        default { 3 }
    }
}
