Import-Module .\O365Essentials.psd1 -Force

# Use WAM for an MFA-aware sign-in and an Azure Resource Manager token.
$Credential = Get-Credential -UserName 'admin@contoso.com' -Message 'Enter the account to use as the WAM login hint'
$null = Connect-O365Admin -UseWam -Credential $Credential -ForceRefresh -Verbose

$BillingAccounts = Get-O365BillingAccounts
$BillingAccounts | Format-Table name, @{ Name = 'AgreementType'; Expression = { $_.properties.agreementType } }

# When AccountId is omitted, supported billing accounts are discovered automatically.
$BillingProfiles = Get-O365BillingProfile
$BillingProfiles | Format-Table name, @{ Name = 'DisplayName'; Expression = { $_.properties.displayName } }
