function Get-O365DomainDependencies {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][string] $DomainName,
        [string][ValidateSet('All', 'Users', 'TeamsAndGroups', 'Apps')] $Type = 'All'
    )
    $Uri = "https://admin.microsoft.com/admin/api/Domains/Dependencies"

    $Types = @{
        'All'    = 0
        'Users'  = 1
        'Groups' = 2
        'Apps'   = 4
    }

    $QueryParameter = @{
        'domainName' = $DomainName
        'kind'       = $Types[$Type]
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter -Method POST
    if ($Output.Succeeded) {
        $Output.Data.Dependencies
    } else {
        [PSCustomObject] @{
            DomainName = $DomainName
            Status     = $false
            Message    = $Output.Message
        }
    }
}