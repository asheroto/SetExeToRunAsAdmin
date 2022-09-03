# SetExeToRunAsAdmin

### Install

On any Windows machine, open PowerShell as Administrator and type...

```
Install-Script SetExeToRunAsAdmin
```

And accept the prompts.

### Usage

```-CurrentUser``` and ```-AllUsers``` flags are optional. If unspecified it will default to ```-CurrentUser```.

Set EXE/EXEs to run as Administrator:

```powershell
SetExeToRunAsAdmin.ps1 -Path <exe path> (-CurrentUser | -AllUsers)
```

Unset EXE/EXEs to run as Administrator:

```powershell
SetExeToRunAsAdmin.ps1 -Path <exe path> (-CurrentUser | -AllUsers) -UnsetInstead
```

### Examples

```powershell
SetExeToRunAsAdmin -Path "C:\Shared\*.exe"

SetExeToRunAsAdmin -Path "C:\Shared\App.exe"

SetExeToRunAsAdmin -Path "C:\Shared\*.exe" -AllUsers

SetExeToRunAsAdmin -Path "C:\Shared\*.exe" -UnsetInstead
```