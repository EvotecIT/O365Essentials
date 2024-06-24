function Get-O365BillingProfile {
    <#
        .SYNOPSIS
        Retrieves billing profile information for a specific billing group in Office 365.
        .DESCRIPTION
        This function retrieves billing profile information for a specified billing group in Office 365 from the designated API endpoint using the provided headers.
        .PARAMETER Headers
        A dictionary containing the necessary headers for the API request, typically including authorization information.
        .EXAMPLE
        Get-O365BillingProfile -Headers $headers
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers
    )
    # But how do I get AccountID ?
    $AccountID = ''
    $Uri = "https://admin.microsoft.com/fd/commerceMgmt/moderncommerce/myroles/BillingGroup?api-version=3.0&accountId=$AccountID"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -Body $Body
    $Output
}
