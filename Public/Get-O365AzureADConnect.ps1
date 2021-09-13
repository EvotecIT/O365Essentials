function Get-O365AzureADConnect {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Headers
    Authorization header as created by Connect-O365Admin. If not provided the function will try to fetch it from the current execution context.

    .EXAMPLE
    Get-O365AzureADConnect -Verbose

    .NOTES
    https://portal.azure.com/#blade/Microsoft_AAD_IAM/PassThroughAuthenticationConnectorsBlade
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://main.iam.ad.ext.azure.com/api/Directories/GetPasswordSyncStatus"
    $Output3 = Invoke-O365Admin -Uri $Uri -Headers $Headers
    #$Output3 | Format-Table

    $Uri = "https://main.iam.ad.ext.azure.com/api/Directories/ADConnectStatus"
    $Output4 = Invoke-O365Admin -Uri $Uri -Headers $Headers

    [PSCustomObject] @{
        passwordSyncStatus               = $Output3
        verifiedDomainCount              = $Output4.verifiedDomainCount              #: 3
        verifiedCustomDomainCount        = $Output4.verifiedCustomDomainCount        #: 2
        federatedDomainCount             = $Output4.federatedDomainCount             #: 0
        numberOfHoursFromLastSync        = $Output4.numberOfHoursFromLastSync        #: 0
        dirSyncEnabled                   = $Output4.dirSyncEnabled                   #: True
        dirSyncConfigured                = $Output4.dirSyncConfigured                #: True
        passThroughAuthenticationEnabled = $Output4.passThroughAuthenticationEnabled #: True
        seamlessSingleSignOnEnabled      = $Output4.seamlessSingleSignOnEnabled      #: True
    }
}