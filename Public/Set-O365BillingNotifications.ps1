function Set-O365BillingNotifications {
    <#
    .SYNOPSIS
    Sets settijngs for Billing notifications (Invoice PDF ON/OFF)

    .DESCRIPTION
    Sets settijngs for Billing notifications (Invoice PDF ON/OFF)

    .PARAMETER Headers
    Parameter description

    .PARAMETER SendInvoiceEmails
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    Sets settings for Billing notifications https://admin.microsoft.com/#/BillingNotifications
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [alias('Authorization')][System.Collections.IDictionary] $Headers,
        [parameter(Mandatory)][bool] $SendInvoiceEmails
    )
    $Uri = "https://admin.microsoft.com/fd/commerceMgmt/mgmtsettings/invoicePreference?api-version=1.0"

    $Body = @{
        sendInvoiceEmails = $SendInvoiceEmails
    }
    $Output = Invoke-O365Admin -Uri $Uri -Headers $Headers -Method POST -Body $Body
    if ($Output.setInvoicePreferenceSuccessful -eq $true) {

    }
}