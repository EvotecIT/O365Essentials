function Get-O365OrgAdoptionScore {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = "https://admin.microsoft.com/admin/api/reports/productivityScoreCustomerOption"
    $OutputSettings = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET
    if ($OutputSettings) {
        if ($OutputSettings.Output) {
            try {
                $OutputSettings.Output | ConvertFrom-Json -ErrorAction Stop
            } catch {
                Write-Warning -Message "Get-O365OrgAdoptionScore - Unable to convert output from JSON $($_.Exception.Message)"
            }
        }
    }
}