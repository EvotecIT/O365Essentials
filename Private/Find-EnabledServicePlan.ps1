function Find-EnabledServicePlan {
    [cmdletbinding()]
    param(
        [Array] $ServicePlans,
        [Array] $DisabledServicePlans
    )
    $CachePlan = @{}
    foreach ($Plan in $ServicePlans) {
        $CachePlan[$Plan.serviceName] = $Plan
    }

    $Plans = [ordered] @{
        Enabled  = $null
        Disabled = $null
    }

    if ($DisabledServicePlans.Count -gt 0) {
        [Array] $Plans['Enabled'] = foreach ($Plan in $ServicePlans) {
            if ($Plan.serviceName -notin $DisabledServicePlans) {
                $Plan
            }
        }
    } else {
        [Array] $Plans['Enabled'] = $ServicePlans
    }
    [Array] $Plans['Disabled'] = foreach ($Plan in $DisabledServicePlans) {
        $CachePlan[$Plan]
    }
    $Plans
}
