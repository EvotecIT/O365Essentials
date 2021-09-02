function Get-O365DomainHealth {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][string] $DomainName
    )
    $Uri = "https://admin.microsoft.com/admin/api/Domains/CheckDnsHealth"

    $QueryParameter = @{
        'domainName'             = $DomainName
        'overrideSkip'           = $true
        'canRefreshCache'        = $true
        'dnsHealthCheckScenario' = 2
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter
    if ($Output.Succeeded) {
        $Output.Data
    } else {
        $Output
    }
}

<#
function Get-O365DomainRegistrarsInformation {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers #,
       # [parameter(Mandatory)][string] $DomainName
    )
    $Uri = "https://admin.microsoft.com/admin/api/Domains/GetRegistrarsHelpInfo"

    $QueryParameter = @{
        #'domainName'             = $DomainName
        #'overrideSkip'           = $true
        #'canRefreshCache'        = $true
        #'dnsHealthCheckScenario' = 2
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter
    $Output
}
#>