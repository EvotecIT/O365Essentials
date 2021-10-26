function Get-O365OrgMicrosoftEdgeSiteLists {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    $Uri = 'https://admin.microsoft.com/fd/edgeenterprisesitemanagement/api/shard'

    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}