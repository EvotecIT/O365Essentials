Import-Module .\O365Essentials.psd1 -Force

if (-not $Credentials) {
    $Credentials = Get-Credential -Message 'Enter the account to use as the WAM login hint'
}

# Use WAM for MFA-aware interactive sign-in. -ForceRefresh is helpful when Windows
# has cached the wrong account and you need the account picker again.
$null = Connect-O365Admin -Verbose -UseWam -Credential $Credentials -ForceRefresh

Get-O365AzureMultiFactorAuthentication -Verbose
