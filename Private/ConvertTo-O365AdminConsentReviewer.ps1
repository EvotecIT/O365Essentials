function ConvertTo-O365AdminConsentReviewer {
    <#
    .SYNOPSIS
    Converts admin consent reviewer objects to the Graph update payload shape.
    #>
    [cmdletbinding()]
    param(
        [object[]] $Reviewer
    )

    foreach ($Item in @($Reviewer)) {
        if (-not $Item) {
            continue
        }

        if ($Item -is [string]) {
            $Query = $Item -replace '^/v1\.0/', '/'
            [ordered] @{
                query     = $Query
                queryType = 'MicrosoftGraph'
            }
            continue
        }

        if ($Item -is [System.Collections.IDictionary]) {
            if ($Item.Contains('query')) {
                $Query = $Item['query'] -replace '^/v1\.0/', '/'
                [ordered] @{
                    query     = $Query
                    queryType = if ($Item.Contains('queryType') -and $Item['queryType']) { $Item['queryType'] } else { 'MicrosoftGraph' }
                }
            }
            continue
        }

        if ($Item.PSObject.Properties.Name -contains 'query') {
            $Query = $Item.query -replace '^/v1\.0/', '/'
            [ordered] @{
                query     = $Query
                queryType = if ($Item.PSObject.Properties.Name -contains 'queryType' -and $Item.queryType) { $Item.queryType } else { 'MicrosoftGraph' }
            }
        }
    }
}
