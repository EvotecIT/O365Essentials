function Get-O365BillingProfile {
    <#
    .SYNOPSIS
    Retrieves billing profile information for a specific billing group in Office 365.

    .DESCRIPTION
    This function retrieves billing profile information for a specified billing group in Office 365 from the designated API endpoint using the provided headers.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER AccountId
    Billing account identifier used by the modern commerce billing profile endpoint.
    If omitted, the function tries to resolve it from Get-O365BillingAccounts output.

    .EXAMPLE
    Get-O365BillingProfile -Headers $headers -AccountId '00000000-0000-0000-0000-000000000000'
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [string] $AccountId
    )

    if ([string]::IsNullOrWhiteSpace($AccountId)) {
        $Account = Get-O365BillingAccounts -Headers $Headers | Select-Object -First 1
        foreach ($PropertyName in 'id', 'accountId', 'billingAccountId') {
            if ($Account -and $Account.PSObject.Properties.Name -contains $PropertyName -and -not [string]::IsNullOrWhiteSpace($Account.$PropertyName)) {
                $AccountId = $Account.$PropertyName
                break
            }
        }
    }

    if ([string]::IsNullOrWhiteSpace($AccountId)) {
        Write-Warning -Message 'Get-O365BillingProfile - AccountId could not be resolved. Provide -AccountId or inspect Get-O365BillingAccounts output.'
        return
    }

    $Uri = "https://admin.microsoft.com/fd/commerceMgmt/moderncommerce/myroles/BillingGroup"
    $QueryParameter = @{
        'api-version' = '3.0'
        accountId     = $AccountId
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method GET -QueryParameter $QueryParameter
    $Output
}
