function Get-AgentOfferRecommendation {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)][string] $ResultName,
        [Parameter(Mandatory)][string] $Uri
    )

    try {
        $Result = Invoke-AgentOverviewRequest -Uri $Uri
        [PSCustomObject] @{
            Name       = $ResultName
            HasOffer   = $null -ne $Result
            NoData     = $null -eq $Result
            DataBacked = $true
            Result     = $Result
        }
    }
    catch {
        New-O365UnavailableResult -Name $ResultName -Area 'Agents overview section' -Description 'The Agents overview section did not return a usable payload.' -ErrorMessage $_.Exception.Message
    }
}
