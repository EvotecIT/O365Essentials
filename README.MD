<p align="center">
  <a href="https://dev.azure.com/evotecpl/O365Essentials/_build/results?buildId=latest"><img src="https://dev.azure.com/evotecpl/O365Essentials/_apis/build/status/EvotecIT.O365Essentials"></a>
  <a href="https://www.powershellgallery.com/packages/O365Essentials"><img src="https://img.shields.io/powershellgallery/v/O365Essentials.svg"></a>
  <a href="https://www.powershellgallery.com/packages/O365Essentials"><img src="https://img.shields.io/powershellgallery/vpre/O365Essentials.svg?label=powershell%20gallery%20preview&colorB=yellow"></a>
  <a href="https://github.com/EvotecIT/O365Essentials"><img src="https://img.shields.io/github/license/EvotecIT/O365Essentials.svg"></a>
</p>

<p align="center">
  <a href="https://www.powershellgallery.com/packages/O365Essentials"><img src="https://img.shields.io/powershellgallery/p/O365Essentials.svg"></a>
  <a href="https://github.com/EvotecIT/O365Essentials"><img src="https://img.shields.io/github/languages/top/evotecit/O365Essentials.svg"></a>
  <a href="https://github.com/EvotecIT/O365Essentials"><img src="https://img.shields.io/github/languages/code-size/evotecit/O365Essentials.svg"></a>
  <a href="https://www.powershellgallery.com/packages/O365Essentials"><img src="https://img.shields.io/powershellgallery/dt/O365Essentials.svg"></a>
</p>

<p align="center">
  <a href="https://twitter.com/PrzemyslawKlys"><img src="https://img.shields.io/twitter/follow/PrzemyslawKlys.svg?label=Twitter%20%40PrzemyslawKlys&style=social"></a>
  <a href="https://evotec.xyz/hub"><img src="https://img.shields.io/badge/Blog-evotec.xyz-2A6496.svg"></a>
  <a href="https://www.linkedin.com/in/pklys"><img src="https://img.shields.io/badge/LinkedIn-pklys-0077B5.svg?logo=LinkedIn"></a>
</p>

# O365Essentials - PowerShell Module

This PowerShell module is highly experimental collection of PowerShell commands to help with Office 365 operations using undocumented and unsupported APIs (among standard graph API calls).
While the module works just fine today, it may break in the future, as it's impossible to tell how and when Microsoft will update the APIs.
As there are no other ways to achive most of the actions done by this module, it is what it is. You either do it via unsupported API or you're stuck using things manually.

This module wouldn't happen without great help from following people:

- [Jannick Oeben](https://twitter.com/JannickOeben)
- [Jos Lieben](https://twitter.com/joslieben)

It is recommended to use **PowerShell 7** or higher. While the module does work in PowerShell 5.1 the error handling of RestMethod is superior in PowerShell 7 so all errors are more readable in it.

I've written a blog post with more information about this module [O365Essentials](https://evotec.xyz/configuring-office-365-settings-using-powershell-the-non-supported-way/).
It contains detailed information about the module, including what's available, how things work and how to use it.

## Installing

Everyone can install this module from **PowerShellGallery** hosted by Microsoft. It's recommended way to work with the module.
Version on **PowershellGallery** is optimized for speed and signed. Using code from **GitHub** is **recommended for development**.

```powershell
Install-Module -Name O365Essentials -AllowClobber -Force
```

Force and AllowClobber aren't necessary, but they do skip errors in case some appear.

## Updating

```powershell
Update-Module -Name O365Essentials
```

That's it. Whenever there's a new version, you run the command, and you can enjoy it. Remember that you may need to close, reopen PowerShell session if you have already used module before updating it.

**The essential thing** is if something works for you on production, keep using it till you test the new version on a test computer. I do changes that may not be big, but big enough that auto-update may break your code. For example, small rename to a parameter and your code stops working! Be responsible!

## Usage

First we need to connect to O365. This is done using Connect-O365Admin command. If we don't have MFA we can automate connection around Credentials.

```powershell
if (-not $Credentials) {
    $Credentials = Get-Credential
}
# This makes a connection to Office 365 tenant
# since we don't want to save the data we null it out
# keep in mind that if there's an MFA you would be better left without Credentials and just let it prompt you
$null = Connect-O365Admin -Verbose -Credential $Credentials
```

If we have MFA we simply let it query you for MFA code.

```powershell
$null = Connect-O365Admin -Verbose
```

We can also connect using an application registration with a client secret or certificate:

```powershell
# using client secret
$null = Connect-O365Admin -ClientId '00000000-0000-0000-0000-000000000000' -ClientSecret 'mySecret'

# using a certificate
$cert = 'C:\path\to\app.pfx'
$null = Connect-O365Admin -ClientId '00000000-0000-0000-0000-000000000000' -Certificate $cert

# using a certificate secured with a password
$certPath = 'C:\path\to\app.pfx'
$certPassword = ConvertTo-SecureString 'P@ssw0rd' -AsPlainText -Force
$null = Connect-O365Admin -ClientId '00000000-0000-0000-0000-000000000000' -Certificate $certPath -CertificatePassword $certPassword
```

When working with multiple tenants you can target a specific tenant using the `-Tenant` or `-DomainName` parameters. This is required for non-interactive connections.

```powershell
$null = Connect-O365Admin -Tenant 'contoso.onmicrosoft.com' -Verbose
```

### Required permissions

The module uses Microsoft Graph, the Azure management API and several
undocumented endpoints under `admin.microsoft.com`. When using a client
secret or certificate, create an app registration in Azure AD and grant it
the permissions below:

* **Microsoft Graph** – at minimum `Directory.ReadWrite.All` and any other
  scopes needed by the commands you plan to run.
* **Azure management** (`https://management.azure.com/`) – delegate or
  application access to `user_impersonation`. If this token can't be acquired
  the connection will still succeed but commands that call the management API
  will warn and exit.
* **Admin portal API** – this API is not documented, so the easiest option is
  to run the app as a user with the Global Administrator role or grant the app
  the same administrative roles.

Interactive connections require the signed‑in account to have the same
permissions. When working non‑interactively remember to specify `-Tenant` or
`-DomainName` to target the correct tenant.

Once the connection is established we can use the module using any GET/SET commands.

```powershell
Get-O365Domain -Verbose | Format-Table

Get-O365DomainHealth -DomainName 'evotec.pl'

$T1 = Get-O365DomainDependencies -DomainName 'evotec.pl' -Type All -Verbose
$T1 | Format-Table
```

For example enabling/disabling some News Settings.

```powershell
Get-O365OrgNews

Set-O365OrgNews -CompanyInformationAndIndustryEnabled $false -ContentOnNewTabEnabled $false -Verbose
Set-O365OrgNews -CompanyInformationAndIndustryEnabled $true -ContentOnNewTabEnabled $true -Verbose
```

All commands are listed [here](COMMANDS.MD). You can check their usage going thru Examples section.
The [SetO365AzureElevatedAccess.ps1](Examples/SetO365AzureElevatedAccess.ps1) script demonstrates how to obtain and remove elevated Azure access using either the current user or a specified UPN. Results from the helper commands are returned directly as objects without requiring a `.value` property.
