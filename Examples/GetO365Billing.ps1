Import-Module .\O365Essentials.psd1 -Force

# Connect-O365Admin uses an interactive OAuth flow supported by Windows PowerShell 5.1
# and PowerShell 7. Use -UseWam on PowerShell 7.4 or newer when broker sign-in is preferred.
$null = Connect-O365Admin -Verbose

$BillingAccounts = Get-O365BillingAccounts
$BillingAccounts | Format-Table name, @{ Name = 'AgreementType'; Expression = { $_.properties.agreementType } }

# When AccountId is omitted, supported billing accounts are discovered automatically.
$BillingProfiles = Get-O365BillingProfile
$BillingProfiles | Format-Table name, @{ Name = 'DisplayName'; Expression = { $_.properties.displayName } }
