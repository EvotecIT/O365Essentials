﻿function Get-O365SearchIntelligenceItemInsights {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/fd/configgraphprivacy/ceb371f6-8745-4876-a040-69f2d10a9d1a/settings/ItemInsights"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    if ($Output) {
        $Return = [PSCustomObject] @{
            AllowItemInsights  = $Output.isEnabledInOrganization
            DisabledForGroup   = $null
            DisabledForGroupID = $Output.disabledForGroup
        }
        if ($Output.DisabledForGroup) {
            $Group = Get-O365Group -Id $Output.DisabledForGroup -Headers $Headers
            if ($Group.id) {
                $Return.DisabledForGroup = $Group.displayName
            }
        }
        $Return
    }
}