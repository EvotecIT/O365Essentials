function Get-O365AzureGroupExpiration {
    <#
    .SYNOPSIS
    Retrieves Azure group expiration information from the specified endpoint.

    .DESCRIPTION
    This function retrieves Azure group expiration information from the specified API endpoint using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER NoTranslation
    A switch parameter to indicate whether to skip translation of the output.

    .EXAMPLE
    Get-O365AzureGroupExpiration -Headers $headers -NoTranslation
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [switch] $NoTranslation
    )
    $Uri = 'https://main.iam.ad.ext.azure.com/api/Directories/LcmSettings'
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method Get
    if ($Output) {
        if ($NoTranslation) {
            $Output
        } else {
            if ($Output.expiresAfterInDays -eq 0) {
                $GroupLifeTime = '180'
            } elseif ($Output.expiresAfterInDays -eq 1) {
                $GroupLifeTime = '365'
            } elseif ($Output.expiresAfterInDays -eq 2) {
                $GroupLifeTime = $Output.groupLifetimeCustomValueInDays
            }

            if ($Output.managedGroupTypes -eq 2) {
                $ExpirationEnabled = 'None'
            } elseif ($Output.managedGroupTypes -eq 1) {
                $ExpirationEnabled = 'Selected'
            } elseif ($Output.managedGroupTypes -eq 0) {
                $ExpirationEnabled = 'All'
            } else {
                $ExpirationEnabled = 'Unknown'
            }
            <#
            expiresAfterInDays             : 2
            groupLifetimeCustomValueInDays : 185
            managedGroupTypesEnum          : 0
            managedGroupTypes              : 0
            adminNotificationEmails        : przemyslaw.klys@evotec.pl
            groupIdsToMonitorExpirations   : {}
            policyIdentifier               : 6f843b54-8fa0-4837-a8e7-b01d00d25892
            #>

            [Array] $Groups = foreach ($ID in $Output.groupIdsToMonitorExpirations) {
                $Group = Get-O365Group -Id $ID
                if ($Group.id) {
                    $Group.DisplayName
                }
            }
            [PSCustomObject] @{
                GroupLifeTime           = $GroupLifeTime
                AdminNotificationEmails = $Output.adminNotificationEmails
                ExpirationEnabled       = $ExpirationEnabled
                ExpirationGroups        = $Groups
            }
        }
    }
}
