[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/asheroto)
# SetExeToRunAsAdmin

`SetExeToRunAsAdmin` is a script that lets you manage administrator privileges for EXE files. You can specify the path of the EXE file using the `-Path` parameter. You 
can also set multiple EXE files to use wildcards to specify multiple files. Additionally, you can choose to modify the administrator setting for the current user or all users on the system using the `-CurrentUser` and `-AllUsers` parameters. To undo the administrator setting, use the `-UnsetInstead` parameter.

## Install

On any Windows machine, open PowerShell as Administrator and type...

```powershell
Install-Script SetExeToRunAsAdmin
```

and accept the prompts.

This script is published on [PowerShell Gallery](https://www.powershellgallery.com/packages/SetExeToRunAsAdmin).

The code is signed, so if you want to change it, just removed the `# SIG # Begin signature block` line and everything beneath it.

## Usage

```powershell
SetExeToRunAsAdmin -Path <exe path/pattern> (-CurrentUser | -AllUsers | -UnsetInstead | -RegJump)
```

## Arguments

|Parameter|Description|Required|
|---|---|---|
|`-Path`|The path of the EXE or pattern to match|Yes, unless using the RegJump switch|
|`-CurrentUser`|Set for the current user (default)
|`-AllUsers`|Set for all users|No|
|`-UnsetInstead`|Unset|No
|`-RegJump`|Use RegJump to jump to the app registry key|No|

## Examples

### Set EXE to run as Administrator

```powershell
SetExeToRunAsAdmin -Path "C:\Shared\example.exe"
```

### Unset EXE to run as Administrator

```powershell
SetExeToRunAsAdmin -Path "C:\Shared\example.exe" -UnsetInstead
```

### Set multiple EXEs to run as Administrator

```powershell
SetExeToRunAsAdmin -Path "C:\Shared\*.exe"
```

### Unset multiple EXEs to run as Administrator

```powershell
SetExeToRunAsAdmin -Path "C:\Shared\*.exe" -UnsetInstead
```

### Jump to user's run as Administrator registry key

```powershell
SetExeToRunAsAdmin -RegJump
```

### Jump to current user's run as Administrator registry key

```powershell
SetExeToRunAsAdmin -CurrentUser -RegJump
```

### Jump to all users' run as Administrator registry key

```powershell
SetExeToRunAsAdmin -AllUsers -RegJump
```