function Get-O365UserSettings {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://main.iam.ad.ext.azure.com/api/Directories/Properties"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET
    $Output
}