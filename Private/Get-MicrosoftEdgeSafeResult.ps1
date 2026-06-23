function Get-MicrosoftEdgeSafeResult {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $ResultName,
        [Parameter(Mandatory)][scriptblock] $ScriptBlock
    )

    try {
        $Result = & $ScriptBlock
        if ($null -eq $Result) {
            if ($ResultName -in @('ConfigurationPolicies', 'ExtensionFeedback')) {
                Write-Output -NoEnumerate @()
            }
            else {
                New-O365UnavailableResult -Name $ResultName -Area 'Microsoft Edge section' -Description 'The Microsoft Edge section did not return a usable payload.'
            }
        }
        else {
            $Result
        }
    }
    catch {
        if ($ResultName -eq 'ExtensionFeedback') {
            New-O365UnavailableResult -Name $ResultName -Area 'Microsoft Edge section' -Description 'The Microsoft Edge extension feedback feed did not return data in the current tenant.' -SuggestedAction 'Validate only if extension feedback is expected for this tenant.' -ErrorMessage $_.Exception.Message -IsOptional $true
        }
        else {
            New-O365UnavailableResult -Name $ResultName -Area 'Microsoft Edge section' -Description 'The Microsoft Edge section did not return a usable payload.' -ErrorMessage $_.Exception.Message
        }
    }
}
