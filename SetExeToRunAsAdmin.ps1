<#PSScriptInfo

.VERSION 0.0.5

.GUID 3e63f459-74c5-4487-bccb-dc10363214f5

.AUTHOR asherto

.COMPANYNAME asheroto

.TAGS PowerShell Windows exe set run remove unset administrator add compatibility admin

.PROJECTURI https://github.com/asheroto/UninstallOneDrive

.RELEASENOTES
[Version 0.0.1] - Initial Release.
[Version 0.0.2] - Fixed example.
[Version 0.0.3] - Added option to unset the exe to run as administrator and refactored function code.
[Version 0.0.4] - Fixed bug in version specification and improved examples.
[Version 0.0.4] - Added project link and improved tags.

#>

<#
.SYNOPSIS
    Sets an EXE to run as Administrator. Usage: SetExeToRunAsAdmin.ps1 -Path <exe path> (-CurrentUser | -AllUsers)
.DESCRIPTION
    Sets an EXE to run as Administrator. Usage: SetExeToRunAsAdmin.ps1 -Path <exe path> (-CurrentUser | -AllUsers)

	Alternatively you can use the -UnsetInstead parameter to unset the exe to run as administrator.
.EXAMPLE
    Set EXE/EXEs to run as Administrator: SetExeToRunAsAdmin.ps1 -Path <exe path> (-CurrentUser | -AllUsers)
.EXAMPLE
	Unset EXE/EXEs to run as Administrator: SetExeToRunAsAdmin.ps1 -Path <exe path> (-CurrentUser | -AllUsers) -UnsetInstead
.EXAMPLE
	Set EXEs to run as Administrator: SetExeToRunAsAdmin.ps1 -Path "C:\Shared\*.exe"
.EXAMPLE
	Unset EXEs to run as Administrator: SetExeToRunAsAdmin.ps1 -Path "C:\Shared\*.exe" -UnsetInstead
.NOTES
    Version      : 0.0.5
    Created by   : asheroto
.LINK
    Project Site: https://github.com/asheroto/SetExeToRunAsAdmin
#>


[CmdletBinding()]
param (
	[Parameter(Mandatory = $true)][String]$Path,
	[Switch]$CurrentUser,
	[Switch]$AllUsers,
	[Switch]$UnsetInstead
)

# Default to CurrentUser
$CompatbilityKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"

# If CurrentUser is specified
if ($CurrentUser) {
	$CompatbilityKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
}

# If LocalMachine is specified
if ($AllUsers) {
	$CompatbilityKey = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
}

function AddRunAsAdministrator {
	param (
		[Parameter(Mandatory = $true)][String]$ExePath,
		[Parameter(Mandatory = $false)][Switch]$UnsetInstead
	)

	if ($UnsetInstead) { # If we want to unset the EXE from running as Administrator
		Remove-ItemProperty -Path $CompatbilityKey -Name $ExePath -ErrorAction SilentlyContinue
	} else { # If we want to set the EXE to run as Administrator
		if ((Get-Item $CompatbilityKey).Property -Contains $ExePath) {
			# If the key's value does not contain RUNASADMIN, then append it, prefixed by space
			$Value = Get-ItemPropertyValue $CompatbilityKey -Name $ExePath
			if (!($Value.Contains("RUNASADMIN"))) {
				Set-ItemProperty $CompatbilityKey -Name $ExePath -Value ($Value + " RUNASADMIN") | Out-Null
			}
		} else {
			# Create a new key with the RUNASADMIN value (with tilde)
			New-ItemProperty $CompatbilityKey -Name $ExePath -Value "~ RUNASADMIN" | Out-Null
		}
	}
}

# Extra line
Write-Output ""

# Create Layers key if it does not exist
if (!(Test-Path $CompatbilityKey)) {
	New-Item $CompatbilityKey -Force | Out-Null
}

$ExeSearch = Get-ChildItem -Path $Path -Filter "*.exe"

if ($UnsetInstead) {
	$ExeSearch | ForEach-Object { Write-Output "Unsetting $($_.Name) to run as administrator"; AddRunAsAdministrator -ExePath $_.FullName -UnsetInstead; }
} else {
	$ExeSearch | ForEach-Object { Write-Output "Setting $($_.Name) to run as administrator"; AddRunAsAdministrator -ExePath $_.FullName; }
}
Write-Output ""

# Inform of registry key
Write-Output "The registry key has been updated:"
Write-Output $CompatbilityKey.Replace(":", "")
Write-Output ""
# SIG # Begin signature block
# MIIp0AYJKoZIhvcNAQcCoIIpwTCCKb0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCD/v4vT0QFwQOjM
# +h4EQJw31AhztgfJC1jZhBNRAv6Bl6CCDrkwggawMIIEmKADAgECAhAIrUCyYNKc
# TJ9ezam9k67ZMA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0z
# NjA0MjgyMzU5NTlaMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQDVtC9C0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0
# JAfhS0/TeEP0F9ce2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJr
# Q5qZ8sU7H/Lvy0daE6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhF
# LqGfLOEYwhrMxe6TSXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+F
# LEikVoQ11vkunKoAFdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh
# 3K3kGKDYwSNHR7OhD26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJ
# wZPt4bRc4G/rJvmM1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQay
# g9Rc9hUZTO1i4F4z8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbI
# YViY9XwCFjyDKK05huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchAp
# QfDVxW0mdmgRQRNYmtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRro
# OBl8ZhzNeDhFMJlP/2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IB
# WTCCAVUwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+
# YXsIiGX0TkIwHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0P
# AQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAC
# hjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAED
# MAgGBmeBDAEEATANBgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql
# +Eg08yy25nRm95RysQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFF
# UP2cvbaF4HZ+N3HLIvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1h
# mYFW9snjdufE5BtfQ/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3Ryw
# YFzzDaju4ImhvTnhOE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5Ubdld
# AhQfQDN8A+KVssIhdXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw
# 8MzK7/0pNVwfiThV9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnP
# LqR0kq3bPKSchh/jwVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatE
# QOON8BUozu3xGFYHKi8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bn
# KD+sEq6lLyJsQfmCXBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQji
# WQ1tygVQK+pKHJ6l/aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbq
# yK+p/pQd52MbOoZWeE4wgggBMIIF6aADAgECAhAOyLAmjUpdRlQheQrwADJFMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjIwNDAxMDAwMDAwWhcNMjMwNDAx
# MjM1OTU5WjCB0zETMBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8AgEC
# EwhPa2xhaG9tYTEdMBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEzARBgNV
# BAUTCjE5MTMwMjk2MDExCzAJBgNVBAYTAlVTMREwDwYDVQQIEwhPa2xhaG9tYTER
# MA8GA1UEBxMITXVza29nZWUxHDAaBgNVBAoTE0FzaGVyIFNvbHV0aW9ucyBJbmMx
# HDAaBgNVBAMTE0FzaGVyIFNvbHV0aW9ucyBJbmMwggIiMA0GCSqGSIb3DQEBAQUA
# A4ICDwAwggIKAoICAQCwsC6ZPJjALlD34NKQyBQp7LMwO61CnMijdMX5VdjqfbII
# 3bTcVIxd9c2VXA4CNHOySle9mwrUKg0/fuSMCL6v+YT+nlykdiGF+1JzF/xztPxi
# UYh/nosuzuJli1cKSqLklo1aJBSbaraI2d2uuEhuZs1bdtNEiDAqB9uzLM1sjdA9
# xMcGqa0a0fWHkiMTgcoTOXttegnjRaOfLjoOHMG885zCbivqvUi1PDw/denxiY8J
# USIlXrfRXG63+HOzp4CyX4BTOdhhljj9KB5WVo8671gBdFFjxG9sjlDpBqT11etn
# ZUS3WUNOx3RnAmUQeriDSlChZuDr4oGS5C2Czwv5tKp/lWsbmBzIlBek0IuxKv+B
# Ve5dIM8lx5o8FV+mHyt9OWPqh1G4I03vS4KQTKs79ck7msPUcWICBb9WUKSFiKbL
# 991jbjY8cviKvI7keQiY+kOP3kH83H8vNSe6cFoFEBFDlq3giO1BYV/36bSsM9xx
# ZgBXQqfMqjqX/HsCRMSRb6aS/GaETq0s9/5ExMJEoLPTN/xi4h+ErLTooX6DgY2Y
# 4Lg5zWeSX3rC9b2/h5SifXxhKDxL8B4V6Pba0mOhc36TcTmPIbz0rBn097i8kuCG
# h11jpqCgfi2jtyyEbsOvEcpnQAwb/SiWbznD0IpNwsnYk5t1hBYx4TTxU8FrNQID
# AQABo4ICODCCAjQwHwYDVR0jBBgwFoAUaDfg67Y7+F8Rhvv+YXsIiGX0TkIwHQYD
# VR0OBBYEFNK8fnBc0Eyw1svglEaxakfmNIEzMDEGA1UdEQQqMCigJgYIKwYBBQUH
# CAOgGjAYDBZVUy1PS0xBSE9NQS0xOTEzMDI5NjAxMA4GA1UdDwEB/wQEAwIHgDAT
# BgNVHSUEDDAKBggrBgEFBQcDAzCBtQYDVR0fBIGtMIGqMFOgUaBPhk1odHRwOi8v
# Y3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JT
# QTQwOTZTSEEzODQyMDIxQ0ExLmNybDBToFGgT4ZNaHR0cDovL2NybDQuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0
# MjAyMUNBMS5jcmwwPQYDVR0gBDYwNDAyBgVngQwBAzApMCcGCCsGAQUFBwIBFhto
# dHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwgZQGCCsGAQUFBwEBBIGHMIGEMCQG
# CCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wXAYIKwYBBQUHMAKG
# UGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNENv
# ZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3J0MAwGA1UdEwEB/wQCMAAw
# DQYJKoZIhvcNAQELBQADggIBABH5uRf88l9+NJ1427Htk3pDHtE1xpJjWI2GNx6H
# ML7PkUqt8VTYOBZcyN/GpQKbp4aA+YNvRK4r/YN3LelR5j+OItSiNcY9f/x0ODfZ
# 90pBvuo+1HCBaZAHhnuiMQFH80ej/vtQ6YtAhphOGjKWEeStCtFp5WD5NNZICBYF
# /omOktMibMWpbR+ya5bT1l/VmnBrMawljkZqy4aKWT4quKb5p1mHcVD2SJxqEKrt
# Ql8iHFR0j96vNnuhWRpYGs38AAx3vWrX/6sGTLXdyrjsHVVYOcRD/DuH2kGXFzmL
# T7/1RGEZJDIQkWDgDJEmjIC98O9uO+gFTwkqkyen3gHj7DzMMtHTnkVe8Efu7Vtf
# qE4EkcPk3eXIL/tEmtr3sXqBKLoNm+c1OUn9PdzZwNFqBgPHZvLKfBtOI1Q/2C88
# fTOEFofJIC2s95MAGMgzHbJOPSWhNRDNkIJbFaGeCxlddb7DoWtKoCZhFtEKtrSF
# h7kzXSvqQqJTsE8z9pB/pRyDNzSYMqDHifZy6rkMkqd7Nv3btUzlyzFxrok3+CDs
# XfwXbO2PJe6HUL2Cvq5lw+1/dsedOoNbdvmX0e84W8tFbJJPs3as1u6OdtRs7tmB
# A/VJxtkZp5vMH4Erdw3ZagCHUGRMX+a5rNzMElHFSkoR5cOt7sKXBzyKx/tI0XgV
# sCHhMYIabTCCGmkCAQEwfTBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNl
# cnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgQ29kZSBTaWdu
# aW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEgQ0ExAhAOyLAmjUpdRlQheQrwADJFMA0G
# CWCGSAFlAwQCAQUAoHwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwG
# CisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZI
# hvcNAQkEMSIEIHM9iWvEkyRZO+f05JRYCZCkMgJurF7eHWa61wFFsnrVMA0GCSqG
# SIb3DQEBAQUABIICAGSKpLDRDdvOiLUGj2pkVK0PfdVD+krYclvEFtJHX5CX4BR9
# JdLE62O72DxuXAUqo0+8aXFooQBNHJQlvZU0/FQ0Y3+QdlpJxh/x34+gX1z9g1Ka
# b2ZDWGA7x1uuiEarDkJwyX5htfuoFNplQRHKEKLdLP1JH4M3j5nnZBGNPi56z7dQ
# rbYZwGfHJZ9PuOeqwi4FYjyposE4DLFljUDyPZ2pTHouAaBl/ivr1/mPbCws6Yw5
# bPpIQRqv2sbIMN0fi671Ml97KxPrTcFcuWdVa6+04hDdEQtMyT+7C1/DxMH8O+rx
# +niDvmdtN704FL+wr14kDVKHvZficHoQ2n7R5cicrVfhIlm+8W3rfHCirfccvUt6
# 5FTOPooFsZPZgQ0LUzKjBNNMgEXScFygj1CFyr02jOQTf+r9T8ha+XH8QpWmC1+c
# 0+uvMZqrPwewggIQsPsGFz8oJKzB3X6p6M17RByOqsQXX53n2uTjkX5hOK0KIWIQ
# GiY1NmLxjyKX3wLYZ+GNtyXMcea0xub8t6+nOdxYm74eNSZsU8r3ZZxRty5ccVr+
# o+3NDWuqo+l7Mjtnut7GzGZ+kG+uCLkV0ViD6mEnY+u4eacTGNCzhJcM7zbZPDUH
# yGJOJI0C7IIpUeH7u1Y1H+1jLMvnIDk8GLv+3WE331gUcTnU28ZIW86CMM9+oYIX
# QzCCFz8GCisGAQQBgjcDAwExghcvMIIXKwYJKoZIhvcNAQcCoIIXHDCCFxgCAQMx
# DzANBglghkgBZQMEAgEFADB3BgsqhkiG9w0BCRABBKBoBGYwZAIBAQYJYIZIAYb9
# bAcBMDEwDQYJYIZIAWUDBAIBBQAEINW0tksHjO5F+HH4kc+bKBmAADyWYuKLmYaP
# Gax7jSuNAhBLrB53+oZiJp80QSfVGSkHGA8yMDIyMDkwMzExMzYyOVqgghMNMIIG
# xjCCBK6gAwIBAgIQCnpKiJ7JmUKQBmM4TYaXnTANBgkqhkiG9w0BAQsFADBjMQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRp
# Z2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENB
# MB4XDTIyMDMyOTAwMDAwMFoXDTMzMDMxNDIzNTk1OVowTDELMAkGA1UEBhMCVVMx
# FzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSQwIgYDVQQDExtEaWdpQ2VydCBUaW1l
# c3RhbXAgMjAyMiAtIDIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC5
# KpYjply8X9ZJ8BWCGPQz7sxcbOPgJS7SMeQ8QK77q8TjeF1+XDbq9SWNQ6OB6zhj
# +TyIad480jBRDTEHukZu6aNLSOiJQX8Nstb5hPGYPgu/CoQScWyhYiYB087DbP2s
# O37cKhypvTDGFtjavOuy8YPRn80JxblBakVCI0Fa+GDTZSw+fl69lqfw/LH09CjP
# QnkfO8eTB2ho5UQ0Ul8PUN7UWSxEdMAyRxlb4pguj9DKP//GZ888k5VOhOl2GJiZ
# ERTFKwygM9tNJIXogpThLwPuf4UCyYbh1RgUtwRF8+A4vaK9enGY7BXn/S7s0psA
# iqwdjTuAaP7QWZgmzuDtrn8oLsKe4AtLyAjRMruD+iM82f/SjLv3QyPf58NaBWJ+
# cCzlK7I9Y+rIroEga0OJyH5fsBrdGb2fdEEKr7mOCdN0oS+wVHbBkE+U7IZh/9sR
# L5IDMM4wt4sPXUSzQx0jUM2R1y+d+/zNscGnxA7E70A+GToC1DGpaaBJ+XXhm+ho
# 5GoMj+vksSF7hmdYfn8f6CvkFLIW1oGhytowkGvub3XAsDYmsgg7/72+f2wTGN/G
# baR5Sa2Lf2GHBWj31HDjQpXonrubS7LitkE956+nGijJrWGwoEEYGU7tR5thle0+
# C2Fa6j56mJJRzT/JROeAiylCcvd5st2E6ifu/n16awIDAQABo4IBizCCAYcwDgYD
# VR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUH
# AwgwIAYDVR0gBBkwFzAIBgZngQwBBAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaA
# FLoW2W1NhS9zKXaaL3WMaiCPnshvMB0GA1UdDgQWBBSNZLeJIf5WWESEYafqbxw2
# j92vDTBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsMy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3Js
# MIGQBggrBgEFBQcBAQSBgzCBgDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGln
# aWNlcnQuY29tMFgGCCsGAQUFBzAChkxodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0Eu
# Y3J0MA0GCSqGSIb3DQEBCwUAA4ICAQANLSN0ptH1+OpLmT8B5PYM5K8WndmzjJeC
# KZxDbwEtqzi1cBG/hBmLP13lhk++kzreKjlaOU7YhFmlvBuYquhs79FIaRk4W8+J
# OR1wcNlO3yMibNXf9lnLocLqTHbKodyhK5a4m1WpGmt90fUCCU+C1qVziMSYgN/u
# SZW3s8zFp+4O4e8eOIqf7xHJMUpYtt84fMv6XPfkU79uCnx+196Y1SlliQ+inMBl
# 9AEiZcfqXnSmWzWSUHz0F6aHZE8+RokWYyBry/J70DXjSnBIqbbnHWC9BCIVJXAG
# cqlEO2lHEdPu6cegPk8QuTA25POqaQmoi35komWUEftuMvH1uzitzcCTEdUyeEpL
# NypM81zctoXAu3AwVXjWmP5UbX9xqUgaeN1Gdy4besAzivhKKIwSqHPPLfnTI/Ke
# GeANlCig69saUaCVgo4oa6TOnXbeqXOqSGpZQ65f6vgPBkKd3wZolv4qoHRbY2be
# ayy4eKpNcG3wLPEHFX41tOa1DKKZpdcVazUOhdbgLMzgDCS4fFILHpl878jIxYxY
# aa+rPeHPzH0VrhS/inHfypex2EfqHIXgRU4SHBQpWMxv03/LvsEOSm8gnK7ZczJZ
# COctkqEaEf4ymKZdK5fgi9OczG21Da5HYzhHF1tvE9pqEG4fSbdEW7QICodaWQR2
# EaGndwITHDCCBq4wggSWoAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcN
# AQELBQAwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcG
# A1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3Rl
# ZCBSb290IEc0MB4XDTIyMDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkG
# A1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdp
# Q2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8Ty
# kTepl1Gh1tKD0Z5Mom2gsMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsm
# c5Zt+FeoAn39Q7SE2hHxc7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTn
# KC3r07G1decfBmWNlCnT2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2
# R/dhgxndX7RUCyFobjchu0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0
# QKfAcsW6Th+xtVhNef7Xj3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/
# oBpHIEPjQ2OAe3VuJyWQmDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1ps
# lPJSlRErWHRAKKtzQ87fSqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhI
# fxQ0z9JMq++bPf4OuGQq+nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8
# I41Y99xh3pP+OcD5sjClTNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkU
# EBIDfV8ju2TjY+Cm4T72wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1G
# nrXTdrnSDmuZDNIztM2xAgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEA
# MB0GA1UdDgQWBBS6FtltTYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC
# 0nFdZEzfLmc/57qYrhwPTzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYB
# BQUHAwgwdwYIKwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSG
# Mmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQu
# Y3JsMCAGA1UdIAQZMBcwCAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0B
# AQsFAAOCAgEAfVmOwJO2b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7
# cIoNqilp/GnBzx0H6T5gyNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2p
# Vs8Vc40BIiXOlWk/R3f7cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxk
# Jodskr2dfNBwCnzvqLx1T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpkn
# G6skHibBt94q6/aesXmZgaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2
# n82HhyS7T6NJuXdmkfFynOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fm
# w0HNT7ZAmyEhQNC3EyTN3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvt
# Cl8zOYdBeHo46Zzh3SP9HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU
# 5vIXmVnKcPA3v5gA3yAWTyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8K
# vYHZE/6/pNHzV9m8BPqC3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/
# GqSFD/yYlvZVVCsfgPrA8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggWNMIIE
# daADAgECAhAOmxiO+dAt5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNV
# BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
# Y2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAe
# Fw0yMjA4MDEwMDAwMDBaFw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# ITAfBgNVBAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC
# 4SmnPVirdprNrnsbhA3EMB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWl
# fr6fqVcWWVVyr2iTcMKyunWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1j
# KS3O7F5OyJP4IWGbNOsFxl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dP
# pzDZVu7Ke13jrclPXuU15zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3
# pC4FfYj1gj4QkXCrVYJBMtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJ
# pMLmqaBn3aQnvKFPObURWBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aa
# dMreSx7nDmOu5tTvkpI6nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXD
# j/chsrIRt7t/8tWMcCxBYKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB
# 4Q+UDCEdslQpJYls5Q5SUUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ
# 33xMdT9j7CFfxCBRa2+xq4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amy
# HeUbAgMBAAGjggE6MIIBNjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC
# 0nFdZEzfLmc/57qYrhwPTzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823I
# DzAOBgNVHQ8BAf8EBAMCAYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhho
# dHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNl
# cnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYD
# VR0fBD4wPDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcN
# AQEMBQADggEBAHCgv0NcVec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxpp
# VCLtpIh3bb0aFPQTSnovLbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6
# mouyXtTP0UNEm0Mh65ZyoUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPH
# h6jSTEAZNUZqaVSwuKFWjuyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCN
# NWAcAgPLILCsWKAOQGPFmCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg6
# 2fC2h5b9W9FcrBjDTZ9ztwGpn1eqXijiuZQxggN2MIIDcgIBATB3MGMxCzAJBgNV
# BAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNl
# cnQgVHJ1c3RlZCBHNCBSU0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAp6
# SoieyZlCkAZjOE2Gl50wDQYJYIZIAWUDBAIBBQCggdEwGgYJKoZIhvcNAQkDMQ0G
# CyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yMjA5MDMxMTM2MjlaMCsGCyqG
# SIb3DQEJEAIMMRwwGjAYMBYEFIUI84ZRXLPTB322tLfAfxtKXkHeMC8GCSqGSIb3
# DQEJBDEiBCC/0R9zn9XOUpT8abdyq8yv7X+aNS0BW9g2QI6A7tffXTA3BgsqhkiG
# 9w0BCRACLzEoMCYwJDAiBCCdppAVw0nGwYl4Rbo1gq1wyI+kKTvbar6cK9JTknnm
# OzANBgkqhkiG9w0BAQEFAASCAgBHTmJ16W6J7BZ1mTSBuebRzRUvSlAzBn2hNRnu
# +cxLD49qcRC67RNeUWXdmZ1AIGUUpwb/PV8o8JbjcLaUzGZY8Pir2kn9BYxW9VeF
# GRGptqoyuU7JZvv2KAXrzSKv+aACQlI/kxxerm7ZKaEpOp/DgfLfkr0KTdEELdFX
# FFlB4/2LIGQEeLNtYp6BHh4K8U4KKYjbjMGD2E8E4ox2dElgDg6SANgpsc3y77Mp
# hq+87tOxeiv3NwXA5nxKoiTCAB+UodBM7sOe0kDHquvxu1QqZqEtCv2eEzhXda5l
# oazlbCQDAMaSPKgjTFcwjE5do0Nzy0/OwgCCDOoLNkESEq/ydJU7YHGMdyy140YR
# CYGn11qVBwUB6zwQoBYSnkEUwaFqiH25PrJ0xt3ykIrPK8y4i5e0tbXP09Sp7VWb
# fIB1NESJA0JhJ34womVN+j2MYlOyK0xBgGh9E1XLMSI7jySPlicgrzbHsUQlrXuj
# Yvc0iUkGwQe64NqPDPD98uKjNKBfXUa8tvwv4aEeEFBTgqnpl0ZdE5JOkI0OIpQW
# DQY1s0APsxqzZwbl05g2FzQfPyLlfstRlwpYIC7yUIx160c1X2TF8WVaCyXHMVYK
# yxhYV093qBEGYGfOePnT/ocbk7g56UCPWricerAd0vEc0QTzf6f30Iak74edZWGu
# pZoDTA==
# SIG # End signature block