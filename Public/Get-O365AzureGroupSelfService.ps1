function Get-O365AzureGroupSelfService {
    <#
    .SYNOPSIS
    Gets Azure Groups Self Service information.

    .DESCRIPTION
    Gets Azure Groups Self Service information.

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

    .EXAMPLE
    Get-O365AzureGroupSelfService

    .NOTES
    General notes
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://main.iam.ad.ext.azure.com/api/Directories/SsgmProperties/'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method Get

    if ($Output) {
        $Output
    }
}
