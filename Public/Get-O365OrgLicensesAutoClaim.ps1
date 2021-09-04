function Get-O365OrgLicensesAutoClaim {
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )

    $Uri = "https://admin.microsoft.com/fd/m365licensing/v1/policies/autoclaim"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}