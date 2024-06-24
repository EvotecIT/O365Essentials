function Get-O365BillingInvoices {
    <#
    .SYNOPSIS
    Gets all invoices from Office 365. If no StartDate and EndDate are specified last 6 months are used.

    .DESCRIPTION
    Gets all invoices from Office 365. If no StartDate and EndDate are specified last 6 months are used.

    .PARAMETER Headers
    Parameter description

    .PARAMETER StartDate
    Provide StartDate for the invoices to be retrieved. If not specified, StartDate is set to 6 months ago.

    .PARAMETER EndDate
    Provide EndDate for the invoices to be retrieved. If not specified, EndDate is set to current date.

    .EXAMPLE
    Get-O365BillingInvoices -Headers $headers -StartDate (Get-Date).AddMonths(-6) -EndDate (Get-Date)

    .NOTES
    This function retrieves invoices from Office 365. If no specific StartDate and EndDate are provided, the function defaults to retrieving invoices from the last 6 months.
    #>
    [cmdletbinding()]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [DateTime] $StartDate,
        [DateTime] $EndDate
    )
    if (-not $StartDate) {
        $StartDate = (Get-Date).AddMonths(-6)
    }
    if (-not $EndDate) {
        $EndDate = Get-Date
    }
    $StartDateText = $StartDate.ToString("yyyy-MM-dd")
    $EndDateText = $EndDate.ToString("yyyy-MM-dd")
    $Uri = "https://admin.microsoft.com/fd/commerceapi/my-org/legacyInvoices(startDate=$StartDateText,endDate=$EndDateText)"
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers
    $Output
}
