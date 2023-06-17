function RunTest {
	[CmdletBinding()]
	param (
		[string]$Command
	)

	# For each command, output the command and then run it
	Write-Output $Command
	Invoke-Expression $Command

	# Write delimiter line
	Write-Output '------------------------'
}

Write-Output ""
Write-Output '------------------------'

# Working commands
RunTest('./SetExeToRunAsAdmin.ps1 -RegJump')
RunTest('./SetExeToRunAsAdmin.ps1 -RegJump -CurrentUser')
RunTest('./SetExeToRunAsAdmin.ps1 -RegJump -AllUsers')

RunTest('./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin\ffmpeg.exe"')
RunTest('./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin\ffmpeg.exe" -UnsetInstead')
RunTest('./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin\ffmpeg.exe" -CurrentUser')
RunTest('./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin\ffmpeg.exe" -CurrentUser -UnsetInstead')
RunTest('./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin\ffmpeg.exe" -AllUsers')
RunTest('./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin\ffmpeg.exe" -AllUsers -UnsetInstead')

RunTest('./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin"')
RunTest('./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin" -UnsetInstead')
RunTest('./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin" -CurrentUser')
RunTest('./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin" -CurrentUser -UnsetInstead')
RunTest('./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin" -AllUsers')
RunTest('./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin" -AllUsers -UnsetInstead')

# Test invalid commands