function Find-EnabledServicePlan {
    <#
        .SYNOPSIS
        Identifies enabled and disabled service plans from a given list.

        .DESCRIPTION
        This function takes two arrays: one containing all service plans and another containing disabled service plans. 
        It returns an ordered dictionary with two keys: 'Enabled' and 'Disabled'. The 'Enabled' key contains an array of service plans that are not in the disabled list, 
        and the 'Disabled' key contains an array of service plans that are in the disabled list.
        
        .PARAMETER ServicePlans
        An array of all available service plans.
        
        .PARAMETER DisabledServicePlans
        An array of service plans that are disabled.
        
        .EXAMPLE
        $allPlans = @('PlanA', 'PlanB', 'PlanC')
        $disabledPlans = @('PlanB')
        $result = Find-EnabledServicePlan -ServicePlans $allPlans -DisabledServicePlans $disabledPlans
        # $result.Enabled will contain 'PlanA' and 'PlanC'
        # $result.Disabled will contain 'PlanB'
        
        .NOTES
        This function is useful for categorizing service plans into enabled and disabled groups.
    #>
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
