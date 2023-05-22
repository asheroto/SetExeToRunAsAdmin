[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/asheroto)

# SetExeToRunAsAdmin

### Install

On any Windows machine, open PowerShell as Administrator and type...

```powershell
Install-Script SetExeToRunAsAdmin
```

And accept the prompts.

This script is published on [PowerShell Gallery](https://www.powershellgallery.com/packages/SetExeToRunAsAdmin).

The code is signed, so if you want to change it, just removed the `# SIG # Begin signature block` line and everything beneath it.

### Usage

```-CurrentUser``` and ```-AllUsers``` flags are optional. If unspecified it will default to ```-CurrentUser```.

Set EXE/EXEs to run as Administrator:

```powershell
SetExeToRunAsAdmin -Path <exe path> (-CurrentUser | -AllUsers)
```

Unset EXE/EXEs to run as Administrator:

```powershell
SetExeToRunAsAdmin -Path <exe path> (-CurrentUser | -AllUsers) -UnsetInstead
```

### Examples

```powershell
SetExeToRunAsAdmin -Path "C:\Shared\*.exe"

SetExeToRunAsAdmin -Path "C:\Shared\App.exe"

SetExeToRunAsAdmin -Path "C:\Shared\*.exe" -AllUsers

SetExeToRunAsAdmin -Path "C:\Shared\*.exe" -UnsetInstead
```