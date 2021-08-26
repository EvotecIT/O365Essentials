function Get-O365DomainTroubleshooting {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][string] $DomainName
    )
    $Uri = "https://admin.microsoft.com/admin/api/Domains/CheckIsTroubleshootingAllowed"

    $QueryParameter = @{
        'domainName'      = $DomainName
        #'overrideSkip'           = $true
        'canRefreshCache' = $true
        #'dnsHealthCheckScenario' = 2
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -QueryParameter $QueryParameter
    $Output
}
