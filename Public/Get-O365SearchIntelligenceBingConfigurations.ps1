function Get-O365SearchIntelligenceBingConfigurations {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/admin/api/searchadminapi/configurations"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers

    if ($Output) {
        [PSCustomObject] @{
            # GUI only allowes single change to all services at once - this means if one is TRUE else is TRUE
            ServiceEnabled = if ($Output.People -eq $true) { $true } else { $false }
            People         = $Output.People
            Groups         = $Output.Groups
            Documents      = $Output.Documents
            Yammer         = $Output.Yammer
            Teams          = $Output.Teams
            TenantState    = $Output.TenantState
        }
    }
}