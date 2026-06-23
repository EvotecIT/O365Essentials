function Get-EdgeSiteListSafeResult {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $ResultName,
        [Parameter(Mandatory)][scriptblock] $ScriptBlock
    )

    try {
        $Result = & $ScriptBlock
        if ($null -eq $Result) {
            if ($ResultName -eq 'Notifications') {
                New-O365UnavailableResult -Name $ResultName -Area 'Microsoft Edge site lists section' -Description 'The Microsoft Edge notifications feed did not return data. This route is optional in some healthy tenants.' -SuggestedAction 'Validate only if Microsoft Edge site list notifications are expected in this tenant.' -IsOptional $true
            }
            else {
                New-O365UnavailableResult -Name $ResultName -Area 'Microsoft Edge site lists section' -Description 'The Microsoft Edge site lists section did not return a usable payload.'
            }
        }
        else {
            $Result
        }
    }
    catch {
        if ($ResultName -eq 'Notifications') {
            New-O365UnavailableResult -Name $ResultName -Area 'Microsoft Edge site lists section' -Description 'The Microsoft Edge notifications feed did not return data. This route is optional in some healthy tenants.' -SuggestedAction 'Validate only if Microsoft Edge site list notifications are expected in this tenant.' -ErrorMessage $_.Exception.Message -IsOptional $true
        }
        else {
            New-O365UnavailableResult -Name $ResultName -Area 'Microsoft Edge site lists section' -Description 'The Microsoft Edge site lists section did not return a usable payload.' -ErrorMessage $_.Exception.Message
        }
    }
}
