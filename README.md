# SetExeToRunAsAdmin

### Install

On any Windows machine, open PowerShell as Administrator and type...

```
Install-Script SetExeToRunAsAdmin
```

And accept the prompts.

### Usage

Set exe/exes to run as Administrator:

```powershell
SetExeToRunAsAdmin.ps1 -Path <exe path> (-CurrentUser | -AllUsers)
```

Unset exe/exes to run as Administrator:

```powershell
SetExeToRunAsAdmin.ps1 -Path <exe path> (-CurrentUser | -AllUsers) -UnsetInstead
```