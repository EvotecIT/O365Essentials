function Set-O365BillingNotifications {
    <#
    .SYNOPSIS
    Sets settings for Billing notifications, allowing control over Invoice PDF delivery.

    .DESCRIPTION
    This function configures the settings for Billing notifications, enabling the user to specify whether to receive Invoice PDFs.

    .PARAMETER Headers
    A dictionary containing the necessary headers for the API request, typically including authorization information.

    .PARAMETER SendInvoiceEmails
    Specifies whether to send Invoice emails. This parameter is mandatory.

    .EXAMPLE
    Set-O365BillingNotifications -Headers $headers -SendInvoiceEmails $true

    .NOTES
    For more information on Billing notifications settings, visit: https://admin.microsoft.com/#/BillingNotifications
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
