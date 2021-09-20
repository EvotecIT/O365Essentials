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

## Changelog

- 0.0.8 - 2021.09.20
  - Added more commands
  - Improved some commands
  - Cleaned up some duplicates
- 0.0.7 - 2021.09.15
  - Added more commands
  - Improved some commands
- 0.0.6 - 2021.09.13
  - Added more commands
- 0.0.5 - 2021.09.10
  - Added new cmdlets
  - Fixes some bugs
- 0.0.4 - 2021.09.10
  - Something went wrong during publish of 0.0.3 - this release fixes it
- 0.0.3 - 2021.09.10
  - Renamed most of commands to be more descriptive
  - Added new commands
  - Fixed some bugs
  - Fixes support for PowerShell 5.1
- 0.0.2 - 2021.08.27
  - Added more commands
- 0.0.1 - 2021.08.19
  - First version