function Set-O365OrgBingDataCollection {
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