function Set-O365OrgBingDataCollection {
    <#
        .SYNOPSIS
        Provides functionality to set consent for Bing data collection in the organization.
        .DESCRIPTION
        This function allows setting consent for Bing data collection in the organization.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .PARAMETER IsBingDataCollectionConsented
        Specifies whether Bing data collection is consented or not.
        .EXAMPLE
        Set-O365OrgBingDataCollection -Headers $headers -IsBingDataCollectionConsented $true
        .NOTES
        For more information, visit: https://admin.microsoft.com/admin/api/settings/security/bingdatacollection
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [nullable[bool]] $IsBingDataCollectionConsented
    )
    $Uri = "https://admin.microsoft.com/admin/api/settings/security/bingdatacollection"

    $Body = [ordered] @{
        IsBingDataCollectionConsented = $IsBingDataCollectionConsented
    }
    $null = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
}
